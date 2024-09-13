class BookingEnquiry < ApplicationRecord
  belongs_to :user
  belongs_to :room
end
