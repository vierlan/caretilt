class RegistrationsController < Devise::RegistrationsController
  before_action :protect_from_spam, only: [:create]

  def create
    super do |resource|
      # LOGIC NOT NEEDED:  CONFIRM LAN AHN

     #if @user.persisted?
     #  send_verification_code(@user.phone_number)
     #end
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
    phone_number = format_phone_number(phone_number)
    client.verify.services(ENV['TWILIO_VERIFY_SERVICE_SID'])
                 .verifications
                 .create(to: phone_number, channel: 'sms')
  end

  def no_entity
    @user = current_user
  end

  def update_no_entity
    @user = current_user
    # Check params[:user][:current_password] to ensure the user is updating their own account
    unless @user.valid_password?(params[:user][:current_password])
      flash[:alert] = "Current password is incorrect."
      redirect_to edit_user_registration_path and return
    end
    if
      params[:user][:is_service_provider] == "1"
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
    if @user.update(no_entity_params)
      redirect_to after_signup_path(:add_name)
    else
      render :no_entity, status: :unprocessable_entity
    end
  end

  private

  def no_entity_params
    params.require(:user).permit(:role, :terms_of_service, :is_service_provider, :la_super_user,:phone_number, :password, :password_confirmation, :email)
  end

  def format_phone_number(number)
    # Ensure the phone number is in E.164 format
    number.start_with?('0') ? "+44#{number[1..-1]}" : number
  end
end
