class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]
  before_action :set_user, only: [:edit, :update]
  def index
    @companies = authorize policy_scope(Company).all
  end

  def show
  end

  def new
    @company = Company.new
  end

  def create
    # Combine the address fields into the registered_address field
    #  params[:company][:registered_address] = [
    #  params[:company][:address1],
    #  params[:company][:address2],
    #  params[:company][:city],
    #  params[:company][:postcode]
    #  ].compact.join(', ')

    @company = Company.new(company_params)

    if @company.save
      redirect_to next_step_path, notice: 'Company created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # @company = current_user.company
    # authorize @company
    authorize :local_authority, :edit?
    @company = case current_user.role
               when 'caretilt_master_user', 'caretilt_user'
                 Company.find(params[:id])
               when 'care_provider_super_user'
                 current_user.company
               else
                 redirect_to dashboard_index_path(current_user),
                             notice: 'You do not have permission to edit this company.' and return
               end
  end

  def update
    logger.debug "Company Params: #{company_params.inspect}"

    # Combine the address fields into the registered_address field
    if @company.update(company_params)
      logger.debug "Company After First Update: #{@company.attributes.inspect}"
      @company.update(registered_address: [
        @company.address1,
        @company.address2,
        @company.city,
        @company.postcode
      ].compact.join(', '))
      redirect_to dashboard_index_path(@company), notice: 'Changes Saved'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  end

  private
  def set_company
    @company = Company.find(params[:id]) || current_user.company
  end

  def set_user
    @user = current_user
  end

  def company_params
    params.require(:company).permit(:website, :address, :name, :phone_number, :companies_house_id, :address1, :address2, :city, :postcode, :logo)
  end

end
