class ActivityFeedsController < ApplicationController
  def index
    @feeds = []
    #get bookings for the companies rooms for the last 2 weeks
    @bookings = current_user.company.care_homes.map(&:rooms).map(&:bookings).where('created_at < ?', 2.weeks.ago)
    @bookings.flatten!.each do |booking|
      booking.attributes.each do |key, value|
        render json: {key => value}
      end
    end



     #get credit logs for the company for the last 2 weeks
    @credit_logs = current_user.company.credit_logs.where('created_at < ?', 2.weeks.ago)

    # get payments for the company for the last 2 weeks
    @payments = current_user.company.payments.where('created_at < ?', 2.weeks.ago)

    # get invoices sent from the company for the last 2 weeks
    @invoices = current_user.company.invoices.where('created_at < ?', 2.weeks.ago)

    # get all the feeds and sort them

    @feeds = @bookings + @credit_logs + @payments + @invoices
    @feeds.sort_by!(&:created_at).reverse!


  end
end