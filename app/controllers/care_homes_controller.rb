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
    @home_types = [
      "Adult Homes",
      "Assisted Living",
      "Continuing Care Retirement Communities",
      "Group Homes",
      "Home Health Care",
      "Hospice Homes",
      "Independent Living",
      "Memory Care Homes",
      "Nursing Home",
      "Residential Care Homes",
      "Supported Living"
    ]
    @client_groups = [
      "Learning Disabilities and/or Autism",
      "Mental Health and/or Autism",
      "Substance Misuse",
      "Physical and/or Sensory Disabilities",
      "Older People",
      "Children and Young People",
      "Children with SEN",
      "Young People / Unaccompanied Minors"
    ]
  end

  def create
    @company = Company.find(params[:company_id])
    @care_home = CareHome.new(care_home_params)
    @care_home.company = @company

    if @care_home.save
      redirect_to dashboard_path(current_user), notice: 'Successfully created'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @company = Company.find(params[:company_id]) # or however you fetch the company
    @care_home = CareHome.find(params[:id])
    @home_types = [
      "Adult Homes",
      "Assisted Living",
      "Continuing Care Retirement Communities",
      "Group Homes",
      "Home Health Care",
      "Hospice Homes",
      "Independent Living",
      "Memory Care Homes",
      "Nursing Home",
      "Residential Care Homes",
      "Supported Living"
    ]
    @client_groups = [
      "Learning Disabilities and/or Autism",
      "Mental Health and/or Autism",
      "Substance Misuse",
      "Physical and/or Sensory Disabilities",
      "Older People",
      "Children and Young People",
      "Children with SEN",
      "Young People / Unaccompanied Minors"
    ]
  end

  def update
    @company = Company.find(params[:company_id])
    @care_home = CareHome.find(params[:id])

    if @company.update(company_params) && @care_home.update(care_home_params)
      redirect_to dashboard_path(current_user), notice: 'Successfully updated'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  end

  private

  def care_home_params
    params.require(:care_home).permit(:name, :phone_number, :website, :address, :email, :address1, :address2, :city, :postcode, :type_of_home, :types_of_client_group, :short_description, photos: [])
  end
end
