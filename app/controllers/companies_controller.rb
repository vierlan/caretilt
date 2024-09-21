class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]
  before_action :set_user, only: [:edit, :update]
  def index
    @companies = Company.all
  end

  def show
  end

  def new
    @company = Company.new
  end

  def create
    # Combine the address fields into the registered_address field
    params[:company][:registered_address] = [
      params[:company][:address],
      params[:company][:address2],
      params[:company][:city],
      params[:company][:postcode]
    ].compact.join(', ')

    @company = Company.new(company_params)

    if @company.save
      redirect_to next_step_path, notice: 'Company created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # Combine the address fields into the registered_address field
    @company.registered_address = [
      params[:company][:address],
      params[:company][:address2],
      params[:company][:city],
      params[:company][:postcode]
    ].compact.join(', ')

    if @company.update(company_params)
      redirect_to next_step_path, notice: 'Company updated successfully.'
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
    params.require(:company).permit(:name, :phone, :companies_house_id, :address, :address2, :city, :postcode)
  end

end
