class Users::TwoFactorAuthenticationController < ApplicationController

  before_action :authenticate_user!

  def show
    # TwilioService.new(current_user).send_otp_twilio

    # Displays OTP Entry form as /user/two_factor_authentication/show
    if request.fullpath != two_factor_authentication_path
      # If not on the OTP page, redirect them there to OTP form
      redirect_to two_factor_authentication_path
    end
  end

#   This controller method handles the web request when the user submits the OTP form. It takes the OTP entered by the user (from params[:otp_code]) and passes it to the service method (TwilioService#verify_otp).
# It orchestrates the flow: it checks the OTP, updates the session, and decides whether to proceed or show an error. It does not directly verify the OTP itself; instead, it delegates that responsibility to the TwilioService.

  # Sends the OTP to the user's phone
  def send_verification
    TwilioService.new(current_user).send_otp_twilio
    # Redirect to the OTP entry page (def show in this controller)
    redirect_to two_factor_authentication_path, notice: 'Verification code sent.'
  end

  # Verifies the OTP entered by the user by sending to Twilio
  def verify_otp
    unless Rails.env.development? #Turn on for SMS verification whilst developing (increase cost)
    # if Rails.env.development? # Turn ON for no SMS verificaiton whilst developing.
      # Simulate OTP verification in development
      session[:two_factor_authenticated] = true
      current_user.update(verified: true)
      redirect_to after_sign_in_path_for(current_user), notice: 'Successfully verified (development mode).'
    else
      code = params[:otp_code]
    
      begin
        if TwilioService.new(current_user).verify_otp_twilio(code)
          # Mark the session as 2FA complete
          session[:two_factor_authenticated] = true
    
          # Mark user as verified
          current_user.update(verified: true)
    
          # Redirect to the user's dashboard or intended destination
          redirect_to after_sign_in_path_for(current_user), notice: 'Successfully verified!'
        else
          flash[:alert] = 'Invalid OTP code. Please try again.'
          redirect_to two_factor_authentication_path
        end
      rescue Twilio::REST::RestError => e
        # Handle errors like invalid code formats or other Twilio issues
        flash[:alert] = "Error verifying OTP: #{e.message}"
        redirect_to two_factor_authentication_path
      end
    end
  end
end
