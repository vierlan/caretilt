class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    if @user.company
    @company = @user.company
    @care_homes = @company.care_homes
    elsif @user.local_authority
      @local_authority = @user.local_authority
      @care_homes = @local_authority.care_homes
    end
  end

  def team
    @team_users = current_user.company.users
    @team_members = @team_users.where(verified: true)
    @company = current_user.company
    @team_super_user = @team_members.find_by(role: 'care_provider_super_user')
    @team_users = @team_members.where(role: 'care_provider_user')
    @care_homes = @company.care_homes
    @unverified_users = @team_users.where(verified: false)
  end
end
