class UsersController < ApplicationController
  before_action :authenticate_user!

  def verify
    @user = current_user
    @company = @user.company
  end

  def verify_user
    @user = current_user
    @company = @user.company
    # Check if the user has entered a valid registration pin and if password is being changed
    if validate_registration_pin(@company) && password_change_requested?
      if request.patch? && @user.update(user_params.except(:registration_pin))
        @user.update(status: 'password_changed') # Update status after successful update
        redirect_to dashboard_team_path(current_user, data: { turbo_frame: "main-content"}), notice: "Password successfully updated."
      else
        flash.now[:alert] = "Error updating password: " + @user.errors.full_messages.to_sentence
        render :edit # or another view to show the form again
      end
    else
      @user.errors.add(:registration_pin, "is invalid") unless validate_registration_pin
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :edit
    end
  end

  private

  def user_params

    params.require(:user).permit(:password, :password_confirmation, :current_password, :registration_pin)
  end

  def validate_registration_pin(company)
    @user = current_user
    @company = company
    # Compare the registration_pin entered by the user with the one for their company
    params[:user][:registration_pin] == @company.registration_pin
  end

  def password_change_requested?
    # Ensure that a new password is being provided and the confirmation matches
    params[:user][:password].present? && params[:user][:password_confirmation].present?
  end
end
