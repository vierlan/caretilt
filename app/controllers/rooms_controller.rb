class RoomsController < ApplicationController
  def index
    @care_home = CareHome.find(params[:care_home_id])
    @company = @care_home.company
    @vacant_rooms = @care_home.rooms.where(vacant: true)
    @home_rooms = @care_home.rooms
    @all_rooms = @care_home.rooms
  end

  def show
    @room = Room.find(params[:id])
    @care_home = @room.care_home
    @company = @care_home.company
  end

  def new
    @care_home = CareHome.find(params[:care_home_id])
    @company = @care_home.company
    @room = Room.new
  end

  def create
    @care_home = CareHome.find(params[:care_home_id])
    @room = Room.new(room_params)
    @room.care_home = @care_home
    @company = @care_home.company
    if @room.save
      redirect_to care_home_rooms_path(@care_home)
    else
      render :new
    end
  end

  def edit
    @care_home = CareHome.find(params[:care_home_id])
    @company = @care_home.company
    @room = Room.find(params[:id])
  end

  def update
    @care_home = CareHome.find(params[:care_home_id])
    @company = @care_home.company
    @room = Room.find(params[:id])

    if @room.update(room_params)
      redirect_to care_home_rooms_path(@care_home)
    else
      render :edit
    end
  end

  def destroy
    @room = Room.find(params[:id])

    @care_home = @room.care_home
    @company = @care_home.company
    @room = Room.find(params[:id])
    @room.destroy

    redirect_to care_home_rooms_path(@care_home)
  end

  private

  def room_params
    params.require(:room).permit(:name, :single_double, :core_fee_level, :core_hours_of_care, :additional_fees_associated, :ensuite, :other_data, :vacant,  photos: [])
  end
end
