class LocalAuthority < ApplicationRecord
  has_many :users
  has_many :subscriptions, as: :subscribable
  has_many :subscriptions, as: :subscribable
  has_many :packages, through: :subscriptions

  def has_active_subscription?
    subscriptions.where(active: true).exists?
  end

  def get_active_subscription
    subscriptions.where(active: true).first
  end
end
