class Company < ApplicationRecord
  has_many :users
  has_many :care_homes
  has_many :rooms, through: :care_homes
  has_many :subscriptions, class_name: 'Subscription', as: :subscribable
  has_many :packages, through: :subscriptions
  has_one_attached :logo

  include Billable

  # include SharedValidAttributes #In models/concerns/shared_valid we are inclusing all phone and address validation since they shared.

  # validates :name, presence: true
  # validates :companies_house_id, presence: true, length: { is: 8 }, format: { with: /\A[A-Z0-9]{8}\z/, message: "must be 8 alphanumeric characters" }

  # checks the company has an active subscription
  def has_active_subscription?
    subscriptions.where(active: true).exists?
  end

  def get_active_subscription
    subscriptions.where(active: true).last
  end
  private


end
