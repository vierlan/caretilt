class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @company = @user.company
    @care_homes = @company.care_homes
  end

  def team; end
end
