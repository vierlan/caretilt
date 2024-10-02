class Package < ApplicationRecord
  has_many :subscriptions
  has_many :companies, through: :subscriptions
end
