class CareHome < ApplicationRecord
  belongs_to :company
  has_many :rooms, dependent: :destroy

  has_many :rooms, dependent: :destroy
  has_many_attached :images
  has_many_attached :videos
  has_many_attached :documents
end
