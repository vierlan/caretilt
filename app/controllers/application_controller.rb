class ApplicationController < ActionController::Base
  impersonates :user

  # uncomment to allow extra User model params during registration (beyond email/password)
  before_action :configure_permitted_parameters, if: :devise_controller?

  def authenticate_admin!(alert_message: nil)
    redirect_to new_user_session_path, alert: alert_message unless current_user&.admin?
  end

  def after_sign_in_path_for(resource)
    dashboard_index_path(current_user)
  end

  def maybe_skip_onboarding
    redirect_to dashboard_index_path, notice: "You're already subscribed" if current_user.finished_onboarding?
  end

  # whitelist extra User model params by uncommenting below and adding User attrs as keys
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:terms_of_service, :role])
  end
end
