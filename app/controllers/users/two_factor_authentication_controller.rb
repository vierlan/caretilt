class Users::TwoFactorAuthenticationController < ApplicationController
  before_action :authenticate_user!, only: [:show, :verify]

  def show
    # Send the OTP when the user reaches this page (the form to input the code)
    send_verification_code_to_user

    # Render the form where the user enters the verification code
  end

  def verify
    # This checks if the verification code entered by the user is correct
    if verify_code(params[:verification_code])
      # If correct, mark user as verified
      current_user.update(verified: true)
      redirect_to after_sign_in_path_for(current_user), notice: 'Phone number successfully verified'
    else
      # If incorrect, show an error message
      flash[:alert] = 'Invalid verification code. Please try again.'
      redirect_to user_verify_path
    end
  end

  private

  # Sends the OTP (One-Time Password) via Twilio when user reaches the verification page
  def send_verification_code_to_user
    TwilioService.new(current_user).send_otp
  end

  # Verifies the code entered by the user using Twilio's API
  def verify_code(code)

    begin
      numeric_code = Integer(code)
    rescue ArgumentError
      flash[:alert] = 'The verification code must be a numeric value.'
      return false
    end
  
    client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
    verification_check = client.verify
                               .services(ENV['TWILIO_VERIFY_SERVICE_SID'])
                               .verification_checks
                               .create(to: current_user.phone_number, code: numeric_code)

    verification_check.status == 'approved'
  end
end
