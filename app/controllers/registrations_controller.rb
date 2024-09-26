class RegistrationsController < Devise::RegistrationsController
  before_action :protect_from_spam, only: [:create]

  def create
    super do |resource|
      # LOGIC NOT NEEDED:  CONFIRM LAN AHN

      # if @user.persisted?
      #   send_verification_code(user.phone_number)
      # end
      # Assign the role based on checkbox selection
      if params[:user][:is_service_provider] == "1"
        resource.role = "care_provider_super_user"
        resource.status = "verified"
        company = Company.create!(name: "New Company")  # Example creation
        resource.company_id = company.id  # Placeholder, assign actual company_id after creation
      elsif params[:user][:la_super_user] == "1"
        resource.role = "la_super_user"
        resource.status = "verified"
        local_authority = LocalAuthority.create!(name: "New Local Authority")  # Example creation
        resource.local_authority_id = local_authority.id
      end

      resource.save!  # Ensure user is saved with the updated fields
    end
  end

  def after_sign_up_path_for(resource)
    after_signup_path(:add_name)
  end

  def send_verification_code(phone_number)
    client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
    client.verify.services(ENV['TWILIO_VERIFICATION_SID'])
                 .verifications
                 .create(to: phone_number, channel: 'sms')
  end




end
