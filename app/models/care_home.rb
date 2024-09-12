class CareHome < ApplicationRecord

  TYPEHOME = ["type1", "type2", "type3"]
  TYPECLIENT = ["type1", "type2", "type3"]

  belongs_to :company
  has_many :users
  has_many :rooms, dependent: :destroy
  has_many_attached :photos
  has_many_attached :videos
  has_many_attached :documents

  # include SharedValidAttributes

  # validates :name, presence: true
  # validates :main_contact, presence: true
  # validates :short_description, presence: true, length: {in 1..50}
  # validates :long_description, length: {in 1.200}
  # validates :type_of_home, presence: true, inclusion: { in: TYPEHOME, message: "%{value} is not a valid home type" }
  # validates :types_of_client_group, presence: true, inclusion: { in: TYPECLIENT, message: "%{value} is not a valid client type" }
end
