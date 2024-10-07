class Package < ApplicationRecord
  has_many :subscriptions, class_name: 'Subscription'
  has_many :companies, through: :subscriptions, source: :subscribable, source_type: 'Company'
  has_many :local_authorities, through: :subscriptions, source: :subscribable, source_type: 'LocalAuthority'

  enum :subscription_type, {:company=>0, :local_authority=>1}
end
