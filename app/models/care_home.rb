class CareHome < ApplicationRecord

  belongs_to :company
  has_many :users
  has_many :rooms, dependent: :destroy
  has_many_attached :photos
  has_many_attached :videos
  has_many_attached :documents
  has_many_attached :media
  has_one_attached :thumbnail_image

  before_save :set_formatted_address
  
  TYPESERVICE = [
    "Assisted Living / Sheltered",
    "Extra Care",
    "Children's Home",
    "Hospice / EoL",
    "Semi Independent Living",
    "Dementia Care Home",
    "Nursing Home",
    "Residential Care Home",
    "Supported Living",
    "Supported Housing",
    "IFA (fostering)"
  ].sort_by { |item| item }

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

 

  include SharedValidAttributes

  validates :name, presence: { message: "Name cannot be blank" }
  validates :main_contact, presence: { message: "Main contact cannot be blank" }
  validates :short_description, presence: { message: "Short description cannot be blank" }, length: { in: 1..300, message: "Short description must be between 1 and 300 characters" }
  validates :long_description, length: { in: 1..800, message: "Long description must be between 1 and 800 characters" }, allow_blank: true
  validates :type_of_home, presence: { message: "Type of service cannot be blank" }, inclusion: { in: TYPESERVICE, message: "%{value} is not a valid home type" }

  # For local authority name check out 'import_local_authorities.rb' under rake.
  # We're getting a csv to make models for each row in the csv to hold data. Then this data can be used for dropdown inclusion depending on attribute.
  validates :local_authority_name, presence: { message: "Local authority cannot be blank" },
  inclusion: { in: ->(_) { cached_local_authority_names },
  message: "%{value} is not a valid local authority" }
  validate :types_of_client_group



  #Used for care home card
  def short_address
    [address1, city, postcode].reject(&:blank?).join(', ')
  end

  # Return the attached thumbnail or a default placeholder image
  def thumbnail_or_default
    if thumbnail_image.attached?
      thumbnail_image
    else
      'logo_symbol.png'
    end
  end
                                        
  private

  # Performance could be an issue plucking the value time, so we're 
  def self.cached_local_authority_names
    @cached_local_authority_names ||= LocalAuthorityData.order(:nice_name).pluck(:nice_name)
  end

  # Method to get the distinct types of homes that are currently in use
  def self.types_in_use
    where.not(type_of_home: nil).distinct.pluck(:type_of_home).sort
  end
  
  def validate_client_groups
    if types_of_client_group.blank?
      errors.add(:types_of_client_group, "cannot be blank")
    else
      invalid_client_groups = types_of_client_group - TYPECLIENT
      if invalid_client_groups.any?
        errors.add(:types_of_client_group, "#{invalid_client_groups.join(', ')} are not valid client types")
      end
    end
  end
  
  def set_formatted_address
    self.formatted_address = [name, address1, address2, city, postcode, country].reject(&:blank?).join(', ')
  end
end
