class BookingEnquiry < ApplicationRecord
  belongs_to :user
  belongs_to :room

  # Each time a booking is made, it will stream it to the activity_feed turbo stream.
  # after_create_commit do
  #   broadcast_append_to 'activity_feed', target: 'activity-feed', partial: 'activity_feeds/card', locals: { booking: self }
  # end
end
