class LocalAuthority < ApplicationRecord
  has_many :users
  has_many :subscriptions, as: :subscribable
  has_many :packages, through: :subscriptions
end
