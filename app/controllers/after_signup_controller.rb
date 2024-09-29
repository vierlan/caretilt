class AfterSignupController < ApplicationController
  include Wicked::Wizard

  steps :add_name, :add_company, :add_local_authority

  def show
    @user = current_user
    case step
    when :add_name
      # No additional setup needed for this step
    when :add_company
      # Assign the existing company or initialize a new one
      @company = @user.company || Company.new
      skip_step if @user.role == "la_super_user"
    when :add_local_authority
      # Assign the existing local authority or initialize a new one
      @local_authority = @user.local_authority || LocalAuthority.new
      skip_step if @user.role == "care_provider_super_user"
    end
    render_wizard
  end

  def update
    @user = current_user
    case step
    when :add_name
      if @user.update(onboarding_params(step))
        render_wizard @user
      else
        render step # Re-render the current step if validation fails
      end
    when :add_company
      @company = @user.company || Company.new
      if @company.update(onboarding_params(step))
        @user.update(company_id: @company.id)  # Ensure the company is associated with the user
        render_wizard @user
      else
        render step
      end
    when :add_local_authority
      @local_authority = @user.local_authority || LocalAuthority.new
      if @local_authority.update(onboarding_params(step))
        @user.update(local_authority_id: @local_authority.id)  # Ensure the local authority is associated with the user
        render_wizard @user
      else
        render step
      end
    end
  end

  def after_sign_in_path_for(resource)
    if resource.verified?
      super
    else
      user_verify_path
    end
  end

  private

  def finish_wizard_path
    dashboard_index_path(current_user)
  end

  def onboarding_params(step = :add_name)
    case step
    when :add_name
      params.require(:user).permit(:first_name, :last_name)
    when :add_company
      params.require(:company).permit(:name, :type, :companies_house_id, :phone_number, :contact_name, :email, :address1, :address2, :city, :postcode, :companies_house_id)
    when :add_local_authority
      params.require(:local_authority).permit(:name)
    end
  end
end
