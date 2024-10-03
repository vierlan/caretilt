class BookingEnquiry < ApplicationRecord
  belongs_to :user
  belongs_to :room, optional: true
  belongs_to :subscription, optional: true

  # Each time a booking is made, it will stream it to the activity_feed turbo stream.
  # after_create_commit do
  #   broadcast_append_to 'activity_feed', target: 'activity-feed', partial: 'activity_feeds/card', locals: { booking: self }
  # end

  validates :contact_name, presence: { message: "Contact name cannot be blank" }, length: { maximum: 100, message: "Contact name cannot be over 100 characters long." }  # Ensure name is not too long
  validates :phone_number, presence: { message: "Contact name cannot be blank" }, length: { maximum: 100, message: "Contact name cannot be over 100 characters long." }  # Ensure name is not too long
  validates :message, presence: { message: "Please leave a note as to what this is regarding to." }, length: { maximum: 500, message: "Please keep the messages short for the first contact." }  # Ensure name is not too long

end
