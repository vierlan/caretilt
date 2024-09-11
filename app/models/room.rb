class Room < ApplicationRecord
  belongs_to :care_home

  has_many_attached :photos
  has_one_attached :video
  has_many_attached :documents

  # validates: :name, presence: true, length: in {1.50}
  # validates: :core_fee_level, presence: true
  # validates: :core_hours_of_care, presence: true
  # validates: :additional_fees_associated, presence: true, inclusion: [true, false]

  # validates: :additional_fees_associated
end
