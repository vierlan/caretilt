class LocalAuthority < ApplicationRecord
  has_many :users
  has_many :subscriptions, class_name: 'Subscription', as: :subscribable
  has_many :packages, through: :subscriptions

  include Billable

  def has_active_subscription?
    subscriptions.where(active: true).exists?
  end

  def get_active_subscription
    subscriptions.where(active: true).last
  end


end
