# This method is responsible for interacting with Twilio's API to verify the OTP. It uses the Twilio client to send the OTP and checks if the OTP matches the one sent via SMS.
# This is a low-level service method, and it directly handles the logic of communicating with Twilio’s Verify API.

class TwilioService
  def initialize(user)
    @user = user
    @client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
  end

  def send_otp_twilio
    phone_number = format_phone_number(@user.phone_number)
    @client.verify
           .services(ENV['TWILIO_VERIFY_SERVICE_SID'])
           .verifications
           .create(to: phone_number, channel: 'sms')
  end

  def verify_otp_twilio(code)
    phone_number = format_phone_number(@user.phone_number)
    verification_check = @client.verify
                                 .services(ENV['TWILIO_VERIFY_SERVICE_SID'])
                                 .verification_checks
                                 .create(to: phone_number, code: code)
    verification_check.status == 'approved' # This returns true if the OTP was valid
  end
  

  private

  def format_phone_number(number)
    # Ensure the phone number is in E.164 format
    number.start_with?('0') ? "+44#{number[1..-1]}" : number
  end
end
