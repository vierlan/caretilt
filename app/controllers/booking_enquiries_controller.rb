class BookingEnquiriesController < ApplicationController
  def new
    @booking = BookingEnquiry.new
    @room = Room.find(params[:room_id])
    @care_home = @room.care_home

  end

  def create
    @booking = BookingEnquiry.new(booking_params)
    @room = Room.find(params[:room_id])
    @care_home = @room.care_home
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
    @bookings = BookingEnquiry.joins(room: { care_home: :company }).where(companies: { id: current_user.company.id })
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
