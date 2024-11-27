class ActivityFeedsController < ApplicationController
  def index
    @feeds = []
    #get bookings for the companies rooms for the last 2 weeks
    @bookings = current_user.company.care_homes.map(&:rooms).map(&:bookings).where('created_at < ?', 4.weeks.ago)
    @bookings.flatten!.each do |booking|
      booking.attributes.each do |key, value|
        render json: {key => value}
      end
    end
     #get credit logs for the company for the last 2 weeks

    # get payments for the company for the last 2 weeks
    @payments = current_user.company.payments.where('created_at < ?', 4.weeks.ago)

    # get invoices sent from the company for the last 2 weeks
    @invoices = current_user.company.invoices.where('created_at < ?', 4.weeks.ago)

    # get all the feeds and sort them
    case current_user.role
    when 'super_admin', 'administrator'
      credit_logs = []
      Company.all.each do |company|
        @credit_logs = company.credit_logs.where('created_at < ?', 2.weeks.ago)
        credit_logs << @credit_logs
      end
      @feeds = @bookings + @credit_logs + @payments + @invoices
    when 'care_provider_super_user', 'care_provider_user'
      @credit_logs = current_user.company.credit_logs.where('created_at < ?', 4.weeks.ago)
      @feeds = @credit_logs + @payments
    when 'la_super_user', 'la_user'
      @feeds = @bookings + @credit_logs + @payments
    end
    @feeds.sort_by!(&:created_at).reverse!
  end
end
