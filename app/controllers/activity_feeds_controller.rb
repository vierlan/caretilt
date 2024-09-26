class ActivityFeedsController < ApplicationController

  def index
    @company = current_user.company
    @care_homes = @company.care_homes
    @bookings = @company.care_homes.map(&:rooms).flatten.map(&:booking_enquiries).flatten.sort_by(&:created_at).reverse
    @credit_logs = @company.get_active_subscriptions.map(&:credit_log)
    @activity_feeds = []
    @booking_log = []
    @bookings.each do |booking|
      @booking_log << "Enquiry:"
      @booking_log << booking.room.name + " - " + booking.room.care_home.name
      @booking_log << booking.created_at
      @booking_log << booking.contact_name
      @booking_log << "Tower Hamlets" # booking.user.local_authority.name
    end
    @credit_logs.each do |log|
      @activity_feeds << log
      end
      raise
      #  sort the activity feeds by created_at desc order
    end



end
