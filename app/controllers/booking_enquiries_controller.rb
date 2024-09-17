class BookingEnquiriesController < ApplicationController
  def new
    @room = Room.find(params[:room_id])
    @care_home = @room.care_home
    @company = @care_home.company
    @booking = BookingEnquiry.new
  end

  def create
    @room = Room.find(params[:room_id])
    @care_home = @room.care_home
    @booking = BookingEnquiry.new(booking_params)
    @booking.room = Room.find(params[:room_id])
    @booking.user = current_user
    @company = @care_home.company
    if @booking.save
      redirect_to care_home_rooms_path(@care_home)
    else
      render :new
    end
  end

  def show
    @booking = BookingEnquiry.find(params[:id])
    @room = @booking.room
    @care_home = @room.care_home
    @company = @care_home.company
    @contact = @booking.user
  end

  def index
    @booking = BookingEnquiry.find(params[:id])
    @room = @booking.room
    @care_home = @room.care_home
    @company = @care_home.company
    @care_home_bookings = @care_home.rooms.map(&:booking_enquiries).flatten
    @company_bookings = @company.care_homes.map(&:rooms).flatten.map(&:booking_enquiries).flatten

  end

  def edit
    @booking = BookingEnquiry.find(params[:id])
    @room = @booking.room
    @care_home = @room.care_home
    @company = @care_home.company
  end

  def update
    @booking = BookingEnquiry.find(params[:id])
    @room = @booking.room
    @care_home = @room.care_home
    @company = @care_home.company

    if @booking.update(booking_params)
      redirect_to care_home_rooms_path(@care_home)
    else
      render :edit
    end
  end

  def destroy
    @booking = BookingEnquiry.find(params[:id])
    @room = @booking.room
    @care_home = @room.care_home
    @company = @care_home.company
    @booking.destroy
    redirect_to care_home_rooms_path(@care_home)
  end

  private

  def booking_params
    params.require(:booking_enquiry).permit(:contact_name, :contact_phone, :service_user_name, :message)
  end
end