class CareHome < ApplicationRecord

  before_save :set_formatted_address
  
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
  ].sort_by { |item| item}

  TYPECLIENT = [
    "Learning Disabilities and/or Autism",
    "Mental Health and/or Autism",
    "Substance Misuse",
    "Physical and/or Sensory Disabilities",
    "Older People",
    "Children and Young People",
    "Children with SEN",
    "Young People / Unaccompanied Minors"
  ].sort_by { |item| item}

  belongs_to :company
  has_many :users
  has_many :rooms, dependent: :destroy
  has_many_attached :photos
  has_many_attached :videos
  has_many_attached :documents

  include SharedValidAttributes

  validates :name, presence: { message: "Name cannot be blank" }
  validates :main_contact, presence: { message: "Main contact cannot be blank" }
  validates :short_description, presence: { message: "Short description cannot be blank" }, length: { in: 1..300, message: "Short description must be between 1 and 300 characters" }
  validates :long_description, length: { in: 1..800, message: "Long description must be between 1 and 800 characters" }, allow_blank: true
  validates :type_of_home, presence: { message: "Type of home cannot be blank" }, inclusion: { in: TYPEHOME, message: "%{value} is not a valid home type" }
  validates :local_authority_name, presence: { message: "Local authority cannot be blank" },
  inclusion: { in: ->(_) { cached_local_authority_names },
  message: "%{value} is not a valid local authority" }
  validate :types_of_client_group



  #Used for care home card
  def short_address
    [address1, city, postcode].reject(&:blank?).join(', ')
  end
                                        
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

  def set_formatted_address
    self.formatted_address = [name, address1, address2, city, postcode, country].reject(&:blank?).join(', ')
  end
# Inclusion Validation: Uses a lambda (->(_) { ... }) to dynamically fetch the nice_name values from the LocalAuthorityData model.
# LocalAuthorityData.pluck(:nice_name): This fetches all nice_name values from the LocalAuthorityData table and returns them as an array. The lambda function ensures that this list is generated at runtime when the validation is checked.
end
