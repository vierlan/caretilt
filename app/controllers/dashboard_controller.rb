class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    if @user.company
    @company = @user.company
    @care_homes = @company.care_homes
    @bookings = @company.care_homes.map(&:rooms).flatten.map(&:booking_enquiries).flatten.sort_by(&:created_at).reverse

    elsif @user.local_authority
      @local_authority = @user.local_authority
      @care_homes = @local_authority.care_homes
    end
  end

  def team
    @team_users = current_user.company.users
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
  end

  def account; end
end
