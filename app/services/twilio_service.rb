class TwilioService
    def initialize(user)
      @user = user
      @client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
    end
  
    def send_otp
      @client.verify
             .services(ENV['TWILIO_VERIFY_SERVICE_SID'])
             .verifications
             .create(to: @user.phone_number, channel: 'sms')
    end
  
    def verify_otp(code)
      verification_check = @client.verify
                                   .services(ENV['TWILIO_VERIFY_SERVICE_SID'])
                                   .verification_checks
                                   .create(to: @user.phone_number, code: code)
  
      verification_check.status == 'approved'
    end
  end
  