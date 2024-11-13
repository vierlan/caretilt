class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :check_two_factor_authentication
  before_action :ensure_onboarding_complete
  before_action :check_verification
  before_action :check_subscription

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
          if log[2] > 2.weeks.ago
            log[5] = company.name
            log[4] = log[4].to_s + " credits left "
            @credit_logs << log
          end
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
    case current_user.role
    when 'caretlit_master_user', 'administrator'
      return true
    when 'care_provider_super_user', 'care_provider_user'
      status = current_user&.company&.get_active_subscription
      Rails.logger.info "Subscription status: #{status}"
    when 'la_super_user', 'la_user'
      status = current_user&.local_authority&.has_active_subscription?
      Rails.logger.info "Subscription status: #{status}"
    end
    unless status && current_user.status == 'verified'
      subscribable = current_user.company || current_user.local_authority
      case current_user.role
      when 'care_provider_super_user' # and subsciption_id present
        # get the subscription id check subscription is valid subscription
        if subscribable.has_active_subscription?
          active_subscription = subscribable.get_active_subscription
          subscription = active_subscription.get_stripe_subscription(subscribable.get_active_subscription.receipt_number)
          Rails.logger.info "Subscription status: #{subscription}"
          period_end = Time.at(subscription[:current_period_end])
          if period_end > active_subscription.expires_on
            active_subscription.update_expiry_date(period_end)
            active_subscription.update(next_payment_date: period_end)
            active_subscription.number_of_payments ? active_subscription.update(number_of_payments: active_subscription.number_of_payments + 1) : active_subscription.update(number_of_payments: 1)
            active_subscription.activate!
            active_subscription.save!
            nil
          elsif period_end > Time.now
            active_subscription.activate!
            active_subscription.save!
            nil
          else
            latest_invoice = active_subscription.get_lastest_stripe_invoice(subscription[:latest_invoice])
            Rails.logger.info "Latest invoice: #{latest_invoice}"
            invoice = active_subscription.fetch_invoice_details(latest_invoice) if latest_invoice.present?
            Rails.logger.info "Invoice: #{invoice}"
            redirect_to invoice.hosted_invoice_url, status: 303, allow_other_host: true, notice: "Please pay your invoice to continue using the service."
          end
        else
          redirect_to packages_path, alert: 'Please subscribe to a package to continue.'
        end
      when 'la_super_user'
        redirect_to packages_path, alert: 'Please subscribe to a package to continue.'
      when 'care_provider_user'
        redirect_to error_path, alert: 'Your company has not subscribed to a package yet.'
      when 'la_user'
        redirect_to error_path, alert: 'Your local authority has not subscribed to a package yet.'
      end
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
      else
        redirect_to error2_path, alert: 'Your account is not yet activated. Please contact your company admin.'
      end
    end
  end

end
