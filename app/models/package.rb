class Package < ApplicationRecord
  has_many :subscriptions
  has_many :companies, through: :subscriptions, source: :subscribable, source_type: 'Company'
  has_many :local_authorities, through: :subscriptions, source: :subscribable, source_type: 'LocalAuthority'

  enum :subscription_type, {:company_subscription=>0, :local_authority_subscription=>1}

  FEATURES = [
    "Added to CareTilt Database",
    "Unlimited Care Homes",
    "Ability to switch void/vacancy on and off as required",
    "Added to Local Authority bulletin",
    "Can receive direct messages from Local Authorities",
    "Full onboarding service",
    "Receive and respond to Local Authority placement bids"
  ]
end
