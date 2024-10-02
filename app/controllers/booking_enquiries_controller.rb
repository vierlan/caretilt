class BookingEnquiriesController < ApplicationController
  def new
    @booking = BookingEnquiry.new
    @user = current_user
    @room = Room.find(params[:room_id])
    @care_home = @room.care_home
    @company = @care_home.company

  end

  def create
    @booking = BookingEnquiry.new(booking_params)
    @room = Room.find(params[:room_id])
    @care_home = @room.care_home
    @company = @care_home.company
    if @booking.save
      redirect_to care_home_rooms_path(@care_home)
    else
      render :new, status: :unprocessable_entity
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
    @user = current_user
    if @user&.company
      @company = @user.company
      @care_homes = @company.care_homes
    @bookings = @company.care_homes.map(&:rooms).flatten.map(&:booking_enquiries).flatten
    elsif @user&.local_authority
      @bookings = BookingEnquiry.where(user: @user)
      @care_homes = @bookings.map { |booking| booking.room.care_home }
    else
      # get all booking enquiries for the last 2 weeks reverse sorted for admin
      @bookings = BookingEnquiry.where('created_at > ?', 2.weeks.ago).order(created_at: :desc)
      @care_homes = @bookings.map { |booking| booking.room.care_home }
    end
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
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @booking = BookingEnquiry.find(params[:id])
    @booking.destroy
    redirect_to care_home_rooms_path(@care_home)
  end

  private

  def booking_params
    params.require(:booking_enquiry).permit(:contact_name, :phone_number, :reference_name, :message)
  end
end
