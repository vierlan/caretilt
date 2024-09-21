class ApplicationController < ActionController::Base
  #before_action :authenticate_user!
  impersonates :user

  # uncomment to allow extra User model params during registration (beyond email/password)
  before_action :configure_permitted_parameters, if: :devise_controller?

  def authenticate_admin!(alert_message: nil)
    redirect_to new_user_session_path, alert: alert_message unless current_user&.admin?
  end

  def after_sign_in_path_for(resource)
    @company = current_user.company

    if current_user.status == 'added'
      verify_path(current_user, data: { turbo_frame: "main-content" })
    else
      if request.format.turbo_stream?
        render turbo_stream: turbo_stream.replace("main-content", partial: "companies/company", locals: { company: @company })
      else
        dashboard_index_path(current_user)
      end
    end
  end

  def maybe_skip_onboarding
    redirect_to dashboard_index_path, notice: "You're already subscribed" if current_user.finished_onboarding?
  end



  # whitelist extra User model params by uncommenting below and adding User attrs as keys
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:terms_of_service, :role])
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
