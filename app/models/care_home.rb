class CareHome < ApplicationRecord

  TYPEHOME = [
    "Adult Homes",
    "Assisted Living",
    "Continuing Care Retirement Communities",
    "Group Homes",
    "Home Health Care",
    "Hospice Homes",
    "Independent Living",
    "Memory Care Homes",
    "Nursing Home",
    "Residential Care Homes",
    "Supported Living"
  ]
  TYPECLIENT = [
    "Learning Disabilities and/or Autism",
    "Mental Health and/or Autism",
    "Substance Misuse",
    "Physical and/or Sensory Disabilities",
    "Older People",
    "Children and Young People",
    "Children with SEN",
    "Young People / Unaccompanied Minors"
  ]

  belongs_to :company
  has_many :users
  has_many :rooms, dependent: :destroy
  has_many_attached :photos
  has_many_attached :videos
  has_many_attached :documents

  include SharedValidAttributes

  validates :name, presence: { message: "Name cannot be blank" }
  validates :main_contact, presence: { message: "Main contact cannot be blank" }
  validates :short_description, presence: { message: "Short description cannot be blank" }, length: { in: 1..50, message: "Short description must be between 1 and 50 characters" }
  validates :long_description, length: { in: 1..200, message: "Long description must be between 1 and 200 characters" }, allow_blank: true
  validates :type_of_home, presence: { message: "Type of home cannot be blank" }, inclusion: { in: TYPEHOME, message: "%{value} is not a valid home type" }
  validates :types_of_client_group, presence: { message: "Types of client group cannot be blank" }, inclusion: { in: TYPECLIENT, message: "%{value} is not a valid client type" }
  validates :local_authority_name, presence: { message: "Local authority cannot be blank" }

  # validates :name, presence: true
  # validates :main_contact, presence: true
  # validates :short_description, presence: true, length: {in 1..50}
  # validates :long_description, length: {in 1.200}
  # validates :type_of_home, presence: true, inclusion: { in: TYPEHOME, message: "%{value} is not a valid home type" }
  # validates :types_of_client_group, presence: true, inclusion: { in: TYPECLIENT, message: "%{value} is not a valid client type" }
end
