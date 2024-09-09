class CareHomesController < ApplicationController
  def index
    @user = current_user
    @company = @user.company
    @care_homes = @company.care_homes

  end

  def show
  end

  def new
    @company = Company.find(params[:company_id])
    @care_home = CareHome.new
  end

  def create
    @company = Company.find(params[:company_id])
    @care_home = CareHome.new(care_home_params)
    @care_home.company = @company

    if @care_home.save
      redirect_to dashboard_path, notice: 'Successfully created'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @company = Company.find(params[:company_id]) # or however you fetch the company
    @care_home = CareHome.find(params[:id]) # o
  end

  def update
    @company = Company.find(params[:company_id])
    @care_home = CareHome.find(params[:id])

    if @company.update(company_params) && @care_home.update(care_home_params)
      redirect_to some_path, notice: 'Successfully updated'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  end

  private

  def care_home_params
    params.require(:care_home).permit(:name, :phone_number, :website, :address, :email)
  end
end
