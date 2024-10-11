class CareHomesController < ApplicationController

  def all
    @user = current_user
    @company = Company.find(params[:company_id])
    @care_homes = @company.care_homes
    @care_homes = @care_homes.map do |care_home|
      {
        care_home: care_home,
        vacant_rooms: care_home.rooms.where(vacant: true),
        lowest_price: care_home.rooms.minimum(:total)
      }
    end
  end

  def index
    # Get only the local authorities that are associated with existing care homes

    @all_local_authorities = LocalAuthorityData.where(nice_name: CareHome.select(:local_authority_name).distinct).sort_by { |item| item}

    @type_of_service_options = ['Any'] + CareHome::TYPESERVICE
    @types_of_client_group_options = CareHome::TYPECLIENT

    # Logic here will return all care homes by default unless front end form specifies filtering params.
    # @care_homes = CareHome.all

    # Use Pundit to scope the care homes based on the user's role
    @care_homes = policy_scope(CareHome)

    if params[:care_home]
      # Local authority filter (if not "Any")
      if params[:care_home][:local_authority_name].present? && params[:care_home][:local_authority_name] != "Any"
        @care_homes = @care_homes.where(local_authority_name: params[:care_home][:local_authority_name])
      end

      # Type of home filter (if not "Any")
      if params[:care_home][:type_of_service].present? && params[:care_home][:type_of_service] != "Any"
        @care_homes = @care_homes.where(type_of_service: params[:care_home][:type_of_service])
      end

      # Types of client group filter (if not "Any")
      if params[:care_home][:types_of_client_group].present? && params[:care_home][:types_of_client_group].reject(&:blank?).any?
        @care_homes = @care_homes.where("types_of_client_group @> ARRAY[?]::varchar[]", params[:care_home][:types_of_client_group].reject(&:blank?))
      end
    end

    # Prepare additional information: vacant rooms and minimum total price
    # In the carehome index we need to show all care homes, but cards needs to display only vacant rooms and lowest prices. Filter here instead of view.
    # Access following in the view by care_home[:key]
    @care_homes = @care_homes.map do |care_home|
      {
        care_home: care_home,
        vacant_rooms: care_home.rooms.where(vacant: true),
        lowest_price: care_home.rooms.minimum(:total)
      }
    end

    respond_to do |format|
      format.html # Renders the default HTML view
    #  format.turbo_stream # Respond to Turbo Stream requests
    end
  end

  def show
    @care_home = CareHome.find(params[:id])
    @rooms = @care_home.rooms.where(vacant: true)
    authorize @care_home

    if @rooms.any?
      @room_cheapest = @rooms.order(:core_fee_level).first
    else
      @room_cheapest = nil
    end

    render "care_homes/show"
  end

  def new
    @company = Company.find(params[:company_id])
    @care_home = CareHome.new

    authorize @care_home

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
      redirect_to dashboard_index_path(current_user), notice: 'Successfully created', status: :see_other, turbo_frame: 'new_home_top'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @care_home = CareHome.find(params[:id])
    @company = @care_home.company
    authorize @care_home

  end

  def update
    @care_home = CareHome.find(params[:id])
    @company = @care_home.company

    authorize @care_home

    # If new media files are uploaded, append them; don't replace the old ones.
    if care_home_params[:media]
      @care_home.media.attach(care_home_params[:media])
    end

    # Handle media reordering if provided
    if params[:media_order].present?
      params[:media_order].each do |media_id, position|
        media = @care_home.media.find(media_id)
        media.update(position: position.to_i)
      end
    end

    # Now update the rest of the attributes (excluding media)
    if @care_home.update(care_home_params.except(:media)) # Exclude media from update, handled separately
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
      # format.turbo_stream # Turbo Stream response for Turbo
    end
  end

  # only used for moving or removing media from care home dynamically

  def move_image
    #Find the car who's images we are re-arranging
    @care_home = CareHome.find(params[:id])
    #Find the image we are moving
    @image = @care_home.images[params[:old_position].to_i - 1]
    # Use the insert_at method we get from acts_as_list gem
    @image.insert_at(params[:new_position].to_i)
    head :ok
  end

  def remove_media
    @care_home = CareHome.find(params[:id])
    media = @care_home.media.find(params[:media_id])
    media_id = media.id
    media.purge

    respond_to do |format|
      format.html { redirect_to edit_care_home_path(@care_home), notice: 'Media removed successfully.' }
      format.turbo_stream { render turbo_stream: turbo_stream.remove("media_#{media_id}") }
    end
  end

  private

  def care_home_params
    params.require(:care_home).permit(
    :name, :main_contact, :phone_number, :website, :address, :email,
    :address1, :address2, :city, :postcode, :type_of_service,
    :short_description, :latitude, :longitude, :local_authority_name,
    :thumbnail_image, photos: [], videos: [], media: [], types_of_client_group: [] # Allow `types_of_client_group` as an array
    ).tap do |whitelisted| #Makes sure that no empty values allowed in the array.
      whitelisted[:types_of_client_group].reject!(&:blank?)
    end
  end
end
