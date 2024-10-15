class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :check_two_factor_authentication
  before_action :ensure_onboarding_complete
  
  def index
    @user = current_user
    @activity_feeds = []
    @booking_log = []

    @care_homes = policy_scope(CareHome)
    if @user.company
      @company = current_user.company
      # @care_homes = policy_scope(@company.care_homes)
      @bookings = @company.care_homes.map(&:rooms).flatten.map(&:booking_enquiries).flatten.sort_by(&:created_at).reverse
      @credit_logs = @company.get_active_subscription&.credit_log
      @activity_feeds.sort_by! { |log| log[2] }.reverse!
    elsif @user.local_authority
      @local_authority = @user.local_authority
      # @care_homes = CareHome.all  # make some logice here which will select care_homes in region/local authority
      # @care_homes = policy_scope(CareHome)
      @bookings = BookingEnquiry.where(user: @user).sort_by(&:created_at).reverse
    else # admin
      @bookings = BookingEnquiry.all.sort_by(&:created_at).reverse
      # @care_homes = CareHome.all
      # get all subscriptions within the last 2 weeks and reverse sort them
      @subscriptions = Subscription.where(created_at: 2.weeks.ago..Time.now).sort_by(&:created_at).reverse
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
    @credit_logs&.each do |log|
      @activity_feeds << log
    end
  end

  def team
    @company = Company.find(params[:id])
    @team_users = @comapny.users
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
