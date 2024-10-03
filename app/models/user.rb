class User < ApplicationRecord
  attr_accessor :terms_of_service, :is_service_provider, :is_local_authority

  belongs_to :company, optional: true
  belongs_to :local_authority, optional: true
  belongs_to :care_home, optional: true
  has_many :booking_enquiries

  include Signupable
  include Onboardable


  scope :subscribed, -> { where.not(stripe_subscription_id: [nil, '']) }

  enum :role, {
  undefined: 0,
  caretilt_master_user: 1,
  caretilt_user: 2,
  care_provider_super_user: 3,
  care_provider_user: 4,
  la_super_user: 5,
  la_user: 6
  }

  # changed to positional enmum
  enum :status, {
    added: 0,
    password_changed: 1,
    verified: 2,
    inactive: 3
  }

  # Lan Ahn:
  # User needs to enter personal mobile on registration (different from company purpose - used for 2FA, has to be model)

  # When adding team member, need field for their phone number. MANDATORY ON SIGN UP. MOBILE UK.


  # Test 2 superuser verified, but didn't make a company.
  # Test 2 then added another user themself, but without a  company attatched. we get dashboard errors.

  # When user is already added (even not in same company) we will get errors when adding.


 # Validation to ensure terms are accepted and role is selected
  validates :terms_of_service, acceptance: { accept: 'on', message: 'must be accepted' }
  # validates :verified, inclusion: { in: [true, false] }
  # validates :first_name, presence: true
  # validates :last_name, presence: true

  before_create :set_verified_default

  def set_verified_default
    self.verified = false if self.verified.nil?
  end

  def full_name
    if self.first_name && self.last_name
    "#{first_name.capitalize} #{last_name.capitalize}"
    else
      self.email
    end
  end

  # :nocov:
  def self.ransackable_attributes(*)
    ["id", "admin", "created_at", "updated_at", "email"]
  end

  def self.ransackable_associations(_auth_object)
    []
  end
  # :nocov:

  # For Wicked Controller. Checks if they filled in basic things (because we can't use rails validations).
  def onboarding_complete?
    first_name.present? && last_name.present? && (company_id.present? || local_authority_id.present?)
  end

end
