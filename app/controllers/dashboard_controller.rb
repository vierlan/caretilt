class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :check_two_factor_authentication
  # ensure registration is completed for super users
  before_action :ensure_onboarding_complete, if: -> { super_user_roles.include?(current_user&.role) }
  before_action :check_verification
  # check subscription status if not admin
  before_action :check_subscription, unless: -> { current_user.role == 'super_admin' || current_user.role == 'administrator' }

  def index
    @user = current_user
    @activity_feeds = []
    @booking_log = []
    @credit_logs = []
    @care_homes = policy_scope(CareHome)
    if current_user.role == 'super_admin' || current_user.role == 'administrator' # admin
      @bookings = BookingEnquiry.all.sort_by(&:created_at).reverse
      # @care_homes = CareHome.all
      # get all subscriptions within the last 2 weeks and reverse sort them
      @subscriptions = Subscription.where(created_at: 2.weeks.ago..Time.now).sort_by(&:created_at).reverse
      Company.all.each do |company|
        @com_credit_logs = company&.get_active_subscription&.credit_log
        @com_credit_logs&.each do |log|
          next unless log[2] > 2.weeks.ago

          log[5] = company.name
          log[4] = log[4].to_s + " credits left "
          @credit_logs << log
        end
      end
    elsif @user.local_authority
      @local_authority = @user.local_authority
      # @care_homes = CareHome.all  # make some logice here which will select care_homes in region/local authority
      # @care_homes = policy_scope(CareHome)
      @bookings = BookingEnquiry.where(user: @user).sort_by(&:created_at).reverse
    else
      @company = current_user.company
      # @care_homes = policy_scope(@company.care_homes)
      @bookings = @company.care_homes.map(&:rooms).flatten.map(&:booking_enquiries).flatten.sort_by(&:created_at).reverse
      @credit_logs = @company.get_active_subscription&.credit_log
    end
    @bookings.each do |booking|
      log = []
      log << "Equiry:"
      log << booking.room.name + " - " + booking.room.care_home.name
      log << booking.created_at
      log << booking.contact_name
      log << booking.user.local_authority.name # booking.user.local_authority.name
      @booking_log << log
    end
    #  sort the activity feeds by activity_time newest to oldest
    @booking_log&.each do |log|
      @activity_feeds << log
    end
    # send credit logs to activity feeds
    @credit_logs&.take(5)&.each do |log|
      @activity_feeds << log
    end
    @activity_feeds.sort_by! { |log| parse_datetime(log[2]) }.reverse!
  end

  def team
    @company = Company.find(params[:id])
    @team_users = @company.users
    @verified_members = @team_users.where.not(status: 0)
    @company = current_user.company
    @team_super_user = @verified_members.find_by(role: 'care_provider_super_user')
    @team_users = @verified_members.where(role: 'care_provider_user')
    @care_homes = @company.care_homes
    @unverified_users = @team_users.where(status: 0)
  end

  def activity_feeds
    @user = current_user
    @company = @user.company
    @care_homes = @company.care_homes
    @bookings = @company.care_homes.map(&:rooms).flatten.map(&:booking_enquiries).flatten.sort_by(&:created_at).reverse
    @activity_feeds = []
  end

  def account; end

  private

  def parse_datetime(value)
    value.is_a?(String) ? DateTime.parse(value) : value
  end

  def check_subscription
    subscribable = current_user.company || current_user.local_authority
    Rails.logger.info("Subscribable: #{subscribable.inspect}")
    Rails.logger.info("Has active subscription: #{subscribable.has_active_subscription?}")

    unless subscribable.has_active_subscription?
      Rails.logger.warn("No active subscription found. Redirecting...")
      redirect_failed_subscription
      return
    end

    active_subscription = subscribable.get_active_subscription
    Rails.logger.info("Active subscription: #{active_subscription.inspect}")

    stripe_subscription = fetch_stripe_subscription(active_subscription) if active_subscription
    Rails.logger.info("Stripe subscription: #{stripe_subscription.inspect}")

    handle_expiry_comparison(active_subscription, stripe_subscription, subscribable)
  end

  def fetch_stripe_subscription(active_subscription)
    Stripe::Subscription.retrieve(active_subscription.receipt_number)
  rescue Stripe::InvalidRequestError => e
    Rails.logger.error("Stripe error: #{e.message}")
    nil # Return nil if Stripe data is unavailable
  end

  def handle_expiry_comparison(active_subscription, stripe_subscription, subscribable)
    stripe_expiry_date = stripe_subscription.present? ? Time.at(stripe_subscription.current_period_end).strftime('%Y-%m-%d') : nil
    local_expiry_date = active_subscription.expires_on.strftime('%Y-%m-%d')
    Rails.logger.info("Local expiry date: #{local_expiry_date}")
    Rails.logger.info("Stripe expiry date: #{stripe_expiry_date}")

    # Allow access if local expiry date is valid and Stripe data is unavailable
    if stripe_expiry_date.nil? && active_subscription.expires_on > Time.now
      Rails.logger.warn("Stripe data unavailable; allowing access based on local expiry date.")
      active_subscription.check_status
      return
    # Update local expiry date if Stripe has newer data
    elsif stripe_expiry_date > local_expiry_date
      Rails.logger.info("Updating local expiry date with Stripe expiry date.")
      update_subscription_expiry(active_subscription, stripe_expiry_date, subscribable)
    # Ensure subscription is active if Stripe expiry is still valid
    elsif stripe_expiry_date > Time.now.strftime('%Y-%m-%d')
      Rails.logger.info("Stripe expiry date is still valid; checking subscription status.")
      active_subscription.check_status
    # Handle unpaid invoices for super users
    elsif super_user_roles.include?(current_user.role)
      handle_super_user_unpaid_invoice(active_subscription, stripe_subscription)
    else
      redirect_failed_subscription
    end
  end

  def update_subscription_expiry(active_subscription, stripe_expiry_date, subscribable)
    active_subscription.update_expiry_date(stripe_expiry_date)
    active_subscription.check_status
    redirect_failed_subscription unless subscribable.has_active_subscription?
    subscribable.add_subscription_credits(active_subscription) if subscribable.is_a?(Company)
  end

  def handle_super_user_unpaid_invoice(active_subscription, stripe_subscription)
    latest_invoice = active_subscription.get_lastest_stripe_invoice(stripe_subscription&.latest_invoice)
    if latest_invoice.present?
      invoice = active_subscription.fetch_invoice_details(latest_invoice)
      redirect_to invoice.hosted_invoice_url, status: 303, allow_other_host: true, notice: "Please pay your invoice to continue using the service."
    else
      redirect_failed_subscription
    end
  end

  def super_user_roles
    %w[care_provider_super_user la_super_user]
  end

  def redirect_failed_subscription
    case current_user.role
    when 'care_provider_super_user'
      redirect_to packages_path, alert: 'Please subscribe to a package to continue.'
    when 'la_super_user'
      redirect_to packages_path, alert: 'Please subscribe to a package to continue.'
    when 'care_provider_user'
      redirect_to error_path, alert: 'Your company has not subscribed to a package yet.'
    when 'la_user'
      redirect_to error_path, alert: 'Your local authority has not subscribed to a package yet.'
    end
  end

  def check_verification
    if current_user.status == 'inactive'
      redirect_to error2_path, alert: 'Your account is not yet activated. Please contact your company admin.'
    end
  end

  def ensure_onboarding_complete
    unless current_user.onboarding_complete?
      # Redirect to the appropriate wizard step if onboarding is not complete
      if current_user.role == 'care_provider_super_user' || current_user.role == 'la_super_user'
        redirect_to after_signup_path(:add_name)
      end
    end
  end

end
