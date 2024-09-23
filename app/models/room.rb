class Room < ApplicationRecord
  belongs_to :care_home
  has_many :booking_enquiries, dependent: :destroy

  has_many_attached :photos
  has_one_attached :video
  has_many_attached :documents

   # Validations
   validates :name, presence: true, length: { maximum: 100 }  # Ensure name is not too long
   validates :core_fee_level, presence: true, numericality: { greater_than_or_equal_to: 0 }
   validates :core_hours_of_care, presence: true, numericality: { only_integer: true, greater_than: 0 }
   validates :single_double, inclusion: { in: ['Single Room', 'Double Room'], message: "must be either 'Single Room' or 'Double Room'" }
   validates :ensuite, inclusion: { in: [true, false] }
   validates :vacant, inclusion: { in: [true, false] }
   validates :additional_fees_associated, inclusion: { in: [true, false] }
   validates :total, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true  # Ensure total is non-negative
  
  # Calculate total after saving or updating
  before_save :update_total

  private

  def update_total
    self.total = core_fee_level * core_hours_of_care
  end
end
