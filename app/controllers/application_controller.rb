class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  include Pundit::Authorization
  # uncomment to allow extra User model params during registration (beyond email/password)
  before_action :configure_permitted_parameters, if: :devise_controller?
  # Pundit: allow-list approach
  # after_action :verify_authorized, except: :index, unless: :skip_pundit?
  # after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  # this part is for warden/session debugging by LanAnh
  def user_for_paper_trail
    Rails.logger.info "User has passed 2FA. #{session["warden.user.user.key"]}"
  end

  def skip_pundit?
    Rails.logger.info "Checking if Devise Controller: #{devise_controller?}"
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)|(^users\/two_factor_authentication$)/ || params[:controller] =~ /(^contact_mailer$)/
  end

  # Needed for pundit to work
  def index
  end

  # Uncomment when you *really understand* Pundit!
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(root_path)
  end

  def authenticate_admin!(alert_message: nil)
    redirect_to new_user_session_path, alert: alert_message unless current_user&.admin?
  end


  def after_sign_in_path_for(resource)
    # Finish resgistration if user hasn't completed it
    if !session[:two_factor_authenticated]
      # If user hasn't passed 2FA, redirect to OTP verification page
      return two_factor_authentication_path
    else
      Rails.logger.info "User has passed 2FA. #{session['warden.user.user.key']}"
    # Proceed with Devise's default behavior once 2FA is verified
    end
    super

  end

  # New method to check 2FA verification
  def check_two_factor_authentication
    # Skip if user is already on the 2FA page to avoid infinite loop
    return if request.path == two_factor_authentication_path

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
    devise_parameter_sanitizer.permit(:sign_up, keys: [:terms_of_service, :role, :phone_number, :privacy_policy])
    devise_parameter_sanitizer.permit(:account_update, keys: [:phone_number, :first_name, :last_name, :cancel_confirmation, :delete_password])
  end

end
