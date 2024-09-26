class ApplicationController < ActionController::Base
  # before_action :authenticate_user!

  impersonates :user

  # uncomment to allow extra User model params during registration (beyond email/password)
  before_action :configure_permitted_parameters, if: :devise_controller?

  def authenticate_admin!(alert_message: nil)
    redirect_to new_user_session_path, alert: alert_message unless current_user&.admin?
  end

  def after_sign_in_path_for(resource)
    if !session[:two_factor_authenticated]
      # If user hasn't passed 2FA, redirect to OTP verification page
      return two_factor_authentication_path
    end

    # Proceed with Devise's default behavior once 2FA is verified
    super
  end

  # New method to check 2FA verification
  def check_two_factor_authentication
    # Skip if user is already on the 2FA page to avoid infinite loop
    return if request.path == two_factor_authentication_path
    Rails.logger.info "Running 2FA check: #{current_user&.verified?}, session[:two_factor_authenticated]: #{session[:two_factor_authenticated]}"

    # Skip if the user has passed 2FA or is not logged in
    return unless current_user && !session[:two_factor_authenticated]

    # Redirect to the OTP verification page if they haven't passed 2FA
    Rails.logger.info "User has not passed 2FA. Redirecting to 2FA page."
    redirect_to two_factor_authentication_path, status: :see_other

  end


  def maybe_skip_onboarding
    redirect_to dashboard_index_path, notice: "You're already subscribed" if current_user.finished_onboarding?
  end



  # whitelist extra User model params by uncommenting below and adding User attrs as keys
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:terms_of_service, :role, :phone_number])
  end

  def verify_user
    @user = current_user
    @company = @user.company

    # Check if the user has entered a valid registration pin and if password is being changed
    if validate_registration_pin && password_change_requested?
      if request.patch? && @user.update(user_params.except(:registration_pin))
        @user.update(status: 'password_changed') # Update status after successful update
        redirect_to root_path, notice: "Password successfully updated."
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

end
