class DashboardController < ApplicationController
  
  before_action :check_two_factor_authentication 

  #def index
  #  @user = current_user
  #  if @user.company
  #    @company = @user.company
  #    @care_homes = @company.care_homes
  #    @bookings = @company.care_homes.map(&:rooms).flatten.map(&:booking_enquiries).flatten.sort_by(&:created_at).reverse
  #  elsif @user.local_authority
  #    @local_authority = @user.local_authority
  #    @care_homes = CareHome.all
  #  end
  #end

  def index
    @company = current_user.company
    @care_homes = @company.care_homes
    @bookings = @company.care_homes.map(&:rooms).flatten.map(&:booking_enquiries).flatten.sort_by(&:created_at).reverse
    @credit_logs = @company.get_active_subscription&.credit_log
    @activity_feeds = []
    @booking_log = []
    @bookings.each do |booking|
      log = []
      log << "Equiry:"
      log << booking.room.name + " - " + booking.room.care_home.name
      log << booking.created_at
      log << booking.contact_name
      log << "Tower Hamlets" # booking.user.local_authority.name
      @booking_log << log
    end
    if @credit_logs
      @credit_logs.each do |log|
      @activity_feeds << log
      end
    end
      #  sort the activity feeds by activity_time newest to oldest
    if @booking_log
      @booking_log.each do |log|
        @activity_feeds << log
      end
    end
      @activity_feeds.sort_by! { |log| log[2] }.reverse!
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
      redirect_to after_signup_path(:add_name)
    end
  end
end
