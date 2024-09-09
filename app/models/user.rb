class User < ApplicationRecord
  attr_accessor :terms_of_service, :is_service_provider, :is_local_authority

  belongs_to :company, optional: true
  belongs_to :local_authority, optional: true

  include Signupable
  include Onboardable
  include Billable

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
  
 # Validation to ensure terms are accepted and role is selected
  validates :terms_of_service, acceptance: { accept: 'on', message: 'must be accepted' }
  
  validates :first_name, presence: true
  validates :last_name, presence: true



  # :nocov:
  def self.ransackable_attributes(*)
    ["id", "admin", "created_at", "updated_at", "email", "stripe_customer_id", "stripe_subscription_id", "paying_customer"]
  end

  def self.ransackable_associations(_auth_object)
    []
  end
  # :nocov:

end
