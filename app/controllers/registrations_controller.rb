class RegistrationsController < Devise::RegistrationsController
  before_action :protect_from_spam, only: [:create]

  def create
    super do |resource|
      # Assign the role based on checkbox selection
      if params[:user][:is_service_provider] == "1"
        resource.role = "care_provider_super_user"
        resource.status = 2
        company = Company.create!(name: "New Company")
        resource.company_id = company.id
      elsif params[:user][:la_super_user] == "1"
        resource.role = "la_super_user"
        resource.status = 2
        local_authority = LocalAuthority.create!(name: "New Local Authority")
        resource.local_authority_id = local_authority.id
      end

      # Ensure user is saved with updated fields
      unless resource.save
        # Stop Devise from rendering/redirecting again
        clean_up_passwords(resource)
        set_minimum_password_length
        render :new, status: :unprocessable_entity
        return
      end
    end
  end

  def update
    resource = current_user

    if params[:user][:cancel_confirmation] == 'cancel'
      if resource.valid_password?(params[:user][:password])
        resource.destroy
        set_flash_message! :notice, :destroyed
        redirect_to root_path and return
      else
        flash[:alert] = 'Password is incorrect'
        render :edit, status: :unprocessable_entity and return
      end
    end

    # Proceed with the regular update if the user isn't deleting the account
    super
  end


  def after_sign_up_path_for(resource)
    after_signup_path(:add_name)
  end

  def send_verification_code(phone_number)
    client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
    phone_number = format_phone_number(phone_number)
    client.verify.services(ENV['TWILIO_VERIFY_SERVICE_SID'])
                 .verifications
                 .create(to: phone_number, channel: 'sms')
  end

  private

  def format_phone_number(number)
    # Ensure the phone number is in E.164 format
    number.start_with?('0') ? "+44#{number[1..-1]}" : number
  end
end
