class RoomsController < ApplicationController
  before_action :set_room, only: %i[edit update]

  def index
    @care_home = CareHome.find(params[:care_home_id])
    @company = @care_home.company
    @vacant_rooms = @care_home.rooms.where(vacant: true)
    @home_rooms = @care_home.rooms
    @all_rooms = @care_home.rooms
    @rooms = policy_scope(Room).all

    #Dirty fix for view.
    @rooms = @home_rooms
  end

  def show
    @room = Room.find(params[:id])
    @care_home = @room.care_home
    authorize @room
    @company = @care_home.company
  end

  def new
    @care_home = CareHome.find(params[:care_home_id])
    @company = @care_home.company
    @room = Room.new
    @room.care_home = @care_home
    authorize @room
  end

  def create
    @care_home = CareHome.find(params[:care_home_id])
    @room = Room.new(room_params)
    @room.care_home = @care_home
    @company = @care_home.company

    authorize @room
    if @room.save
      if @room.vacant? # If room is created with vacant box checked, call the deduct_credit method
        subscription = current_user.company.get_active_subscription
        subscription.deduct_credit(@room)
      end
      flash[:notice] = "Room created successfully."
      redirect_to care_home_rooms_path(@care_home)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @room
    @care_home = @room.care_home
    @company = @care_home.company
  end

  def update

    @room.assign_attributes(room_params)
    authorize @room

    # If room is updated to vacant, call the deduct_credit method
    if @room.save
      if @room.vacant_previously_changed? && @room.vacant?
        subscription = @room.company.get_active_subscription
        subscription.deduct_credit(@room)
      end
      flash[:notice] = "Room updated successfully."
      redirect_to care_home_path(@room.care_home), data: { turbo_frame: "main-content"}
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @room = Room.find(params[:id])
    authorize @room
    @care_home = @room.care_home
    @company = @care_home.company
    @room = Room.find(params[:id])
    @room.destroy
    redirect_to care_home_rooms_path(@care_home)
  end

  private

  def set_room
    @room = Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(:name, :single_double, :core_fee_level, :core_hours_of_care, :additional_fees_associated, :ensuite, :other_data, :vacant,  photos: [])
  end
end
