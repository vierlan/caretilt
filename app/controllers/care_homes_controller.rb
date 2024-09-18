class CareHomesController < ApplicationController

  def all
    @user = current_user
    @company = @user.company
    @care_homes = @company.care_homes
  end

  def index
    # Get only the local authorities that are associated with existing care homes
    @all_local_authorities = LocalAuthorityData.where(nice_name: CareHome.select(:local_authority_name).distinct)

    # Filter care homes if a local authority is selected
    if params[:care_home] && params[:care_home][:local_authority_name].present?
      @care_homes = CareHome.where(local_authority_name: params[:care_home][:local_authority_name])
    else
      @care_homes = CareHome.all
    end

    respond_to do |format|
      format.html # Renders the default HTML view
      format.turbo_stream # Respond to Turbo Stream requests
    end

  end

  def show
    @care_home = CareHome.find(params[:id])
    @rooms = @care_home.rooms
    render "care_homes/show"
  end

  def new
    @company = Company.find(params[:company_id])
    @care_home = CareHome.new
    # @home_types = [
    #   "Adult Homes",
    #   "Assisted Living",
    #   "Continuing Care Retirement Communities",
    #   "Group Homes",
    #   "Home Health Care",
    #   "Hospice Homes",
    #   "Independent Living",
    #   "Memory Care Homes",
    #   "Nursing Home",
    #   "Residential Care Homes",
    #   "Supported Living"
    # ]
    # @client_groups = [
    #   "Learning Disabilities and/or Autism",
    #   "Mental Health and/or Autism",
    #   "Substance Misuse",
    #   "Physical and/or Sensory Disabilities",
    #   "Older People",
    #   "Children and Young People",
    #   "Children with SEN",
    #   "Young People / Unaccompanied Minors"
    # ]
    if @care_home.save
      redirect_to dashboard_index_path(current_user), notice: 'Successfully created'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def create
    @company = Company.find(params[:company_id])
    @care_home = CareHome.new(care_home_params)
    @care_home.company = @company

    if @care_home.save
      redirect_to dashboard_index_path(current_user), notice: 'Successfully created'
    else
      render :new, status: :unprocessable_entity
      # raise
    end
  end

  def edit
    @care_home = CareHome.find(params[:id])
    @company = @care_home.company
    

    # @home_types = [
    #   "Adult Homes",
    #   "Assisted Living",
    #   "Continuing Care Retirement Communities",
    #   "Group Homes",
    #   "Home Health Care",
    #   "Hospice Homes",
    #   "Independent Living",
    #   "Memory Care Homes",
    #   "Nursing Home",
    #   "Residential Care Homes",
    #   "Supported Living"
    # ]
    # @client_groups = [
    #   "Learning Disabilities and/or Autism",
    #   "Mental Health and/or Autism",
    #   "Substance Misuse",
    #   "Physical and/or Sensory Disabilities",
    #   "Older People",
    #   "Children and Young People",
    #   "Children with SEN",
    #   "Young People / Unaccompanied Minors"
    # ]
  end

  def update
    @care_home = CareHome.find(params[:id])
    @company = @care_home.company

    if @care_home.update(care_home_params)
      redirect_to dashboard_index_path(current_user), notice: 'Successfully updated'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @care_home = CareHome.find(params[:id])
    @care_home.destroy

    respond_to do |format|
      format.html { redirect_to care_homes_path, notice: 'Care home was successfully deleted.' }
      format.turbo_stream # Turbo Stream response for Turbo
    end
  end

  private

  def care_home_params
    params.require(:care_home).permit(:name, :main_contact,:phone_number, :website, :address, :email, :address1, :address2, :city, :postcode, :type_of_home, :types_of_client_group, :short_description, :latitude, :longitude, :local_authority_name, photos: [])
  end
end
