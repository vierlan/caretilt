class User < ApplicationRecord
  belongs_to :company, optional: true
  belongs_to :local_authority, optional: true

  include Signupable
  include Onboardable
  include Billable

  scope :subscribed, -> { where.not(stripe_subscription_id: [nil, '']) }

  enum role: {
    undefined: 0,
    caretilt_master_user: 1,
    caretilt_user: 2,
    care_provider_super_user: 3,
    care_provider_user: 4,
    la_super_user: 5,
    la_user: 6
  }

  # :nocov:
  def self.ransackable_attributes(*)
    ["id", "admin", "created_at", "updated_at", "email", "stripe_customer_id", "stripe_subscription_id", "paying_customer"]
  end

  def self.ransackable_associations(_auth_object)
    []
  end
  # :nocov:
end
