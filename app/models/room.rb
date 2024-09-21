class Room < ApplicationRecord
  belongs_to :care_home
  has_many :booking_enquiries, dependent: :destroy

  has_many_attached :photos
  has_one_attached :video
  has_many_attached :documents

  validates :name, presence: true
  validates :core_fee_level, presence: true, numericality: { greater_than_or_equal_to: 0 } # Assuming core_fee_level is a number
  validates :core_hours_of_care, presence: true, numericality: { only_integer: true, greater_than: 0 } # Assuming core_hours_of_care is an integer
  validates :additional_fees_associated, inclusion: { in: [true, false] } # Boolean validation
  
end
