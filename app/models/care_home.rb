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
  validate :types_of_client_group
  validates :local_authority_name, presence: { message: "Local authority cannot be blank" },
                                  inclusion: { in: ->(_) { cached_local_authority_names },
                                              message: "%{value} is not a valid local authority" }
  private

  def self.cached_local_authority_names
    @cached_local_authority_names ||= LocalAuthorityData.pluck(:nice_name)
  end
  
  def validate_client_groups
    invalid_client_groups = types_of_client_group - TYPECLIENT
    if invalid_client_groups.any?
      errors.add(:types_of_client_group, "#{invalid_client_groups.join(', ')} are not valid client types")
    end
  end
# Inclusion Validation: Uses a lambda (->(_) { ... }) to dynamically fetch the nice_name values from the LocalAuthorityData model.
# LocalAuthorityData.pluck(:nice_name): This fetches all nice_name values from the LocalAuthorityData table and returns them as an array. The lambda function ensures that this list is generated at runtime when the validation is checked.
end
