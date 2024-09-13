class AccountController < ApplicationController
  def index
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(account_update_params)
      redirect_to account_path(@user), notice: 'Account was successfully updated.'
    else
      render :index
    end
  end

  private

  def account_update_params
    params.require(:user).permit(:email, :password)
  end
end
