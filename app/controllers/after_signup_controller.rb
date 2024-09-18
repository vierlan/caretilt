class AfterSignupController < ApplicationController
  include Wicked::Wizard

  steps :add_name, :add_company, :add_local_authority

  def show
    @user = current_user
    case step
    when :add_name

    when :add_company
      @company = Company.new
      skip_step if @user.role == "la_super_user"
    when :add_local_authority
      @local_authority = LocalAuthority.new
      skip_step if @user.role == "care_provider_super_user"
    end
    render_wizard
  end

  def update
    @user = current_user
    case step
    when :add_name
      @user.update(onboarding_params(step))
    when :add_company
      @company = @user.company || Company.new(onboarding_params(step))
      @company.update(onboarding_params(step))
      @user.update(company_id: @company.id)  # Ensure the company is associated with the user
    when :add_local_authority
      @local_authority = @user.local_authority || LocalAuthority.new(onboarding_params(step))
      @local_authority.update(onboarding_params(step))
      @user.update(local_authority_id: @local_authority.id)  # Ensure the local authority is associated with the user
    end

    # Render the next step in the wizard flow
    render_wizard @user
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
      params.require(:company).permit(:name, :type, :companies_house_id, :registered_address, :phone_number, :contact_name, :email, :address, :address2, :city, :postcode, :companies_house_id)
    when :add_local_authority
      params.require(:local_authority).permit(:name)
    end
  end


end
