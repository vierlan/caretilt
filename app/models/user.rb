class User < ApplicationRecord
  attr_accessor :terms_of_service, :is_service_provider, :is_local_authority, :privacy_policy, :cancel_confirmation, :delete_password

  belongs_to :company, optional: true
  belongs_to :local_authority, optional: true
  belongs_to :care_home, optional: true
  has_many :booking_enquiries

  include Signupable
  include Onboardable

  scope :subscribed, -> { where.not(stripe_subscription_id: [nil, '']) }

  enum :role, {
    undefined: 0,
    super_admin: 1,
    administrator: 2,
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


  # User needs to enter personal mobile on registration (different from company purpose - used for 2FA, has to be model)

  PASSWORD_REQUIREMENTS = /\A
  (?=.{8,}) # at least 8 characters
  (?=.*[A-Z]) # uppercase
  (?=.*[a-z]) # lowercase
  (?=.*[0-9]) # digits
  (?=.*[[:^alnum:]]) # special characters
/x

  # Validation to ensure terms are accepted and role is selected
  validates :terms_of_service, acceptance: { accept: 'on', message: 'must be accepted' }
  validates :privacy_policy, acceptance: { accept: 'on', message: 'must be accepted' }
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
  validate :password_complexity
  # validates :phone_number,  format: { with: /^\+?(\d{1,3})?[-.\s]?(\(?\d{3}\)?[-.\s]?)?(\d[-.\s]?){6,9}\d$/, on: :create }

  # validates :email,
  #          format: { with: Devise.email_regexp },
  #          presence: true,
  #          uniqueness: { case_insensitive: true }

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

  def password_complexity
    # Regexp extracted from https://stackoverflow.com/questions/19605150/regex-for-password-must-contain-at-least-eight-characters-at-least-one-number-a
    return if password.blank? || password =~ /^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,70}$/

    errors.add :password, 'Complexity requirement not met. Length should be 8-70 characters and include: 1 uppercase, 1 lowercase, 1 digit and 1 special character'
  end
end
