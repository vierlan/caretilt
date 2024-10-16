class Room < ApplicationRecord
  belongs_to :care_home
  delegate :company, to: :care_home
  has_many :booking_enquiries, dependent: :destroy


   # Validations
   validates :name, presence: { message: "Name cannot be blank" }, length: { maximum: 100, message: "Name cannot be over 100 characters long." }  # Ensure name is not too long
   validates :core_fee_level, presence: true, numericality: { greater_than_or_equal_to: 0, message: "Fee needs to be above 0." }
   validates :core_hours_of_care, presence: { message: "Core hours of care cannot be blank"} , numericality: { only_integer: true, greater_than: 0, message: "Core hours of care needs to be above 0" }
   validates :single_double, inclusion: { in: ['Single Room', 'Double Room'], message: "must be either 'Single Room' or 'Double Room'" }
   validates :ensuite, inclusion: { in: [true, false], message: "Ensuite needs to be either true or false" }
   validates :vacant, inclusion: { in: [true, false], message: "Room vacancy can only be either true or false" }
   validates :additional_fees_associated, inclusion: { in: [true, false], message: "additional fees associated can only be either true or false" }
   validates :total, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true  # Ensure total is non-negative

  # Calculate total after saving or updating
  before_save :update_total

  private

  def update_total
    self.total = core_fee_level * core_hours_of_care
  end
end
