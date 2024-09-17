class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_onboarding_complete, only: [:index, :team, :account]

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
    @verified_members = @team_users.where.not(status: 0)
    @company = current_user.company
    @team_super_user = @verified_members.find_by(role: 'care_provider_super_user')
    @team_users = @verified_members.where(role: 'care_provider_user')
    @care_homes = @company.care_homes
    @unverified_users = @team_users.where(status: 0)
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
