class Company < ApplicationRecord
  attr_accessor :address, :address2, :city, :postcode


  include Billable


  TYPES = ["type1", "type2", "type3"]

  after_create do
    Rails.logger.info("Creating Stripe customer for #{self.name}")
    company = Stripe::Customer.create(name: self.name, email: self.email)
    Rails.logger.info("Stripe customer created: #{company.name}")
  end

  # include SharedValidAttributes #In models/concerns/shared_valid we are inclusing all phone and address validation since they shared.

  # validates :name, presence: true
  # validates :companies_house_id, presence: true, length: { is: 8 }, format: { with: /\A[A-Z0-9]{8}\z/, message: "must be 8 alphanumeric characters" }
  # validates :type, presence: true, inclusion: { in: TYPES, message: "%{value} is not a valid company type" }

  # Check phone number validation on country - TBC

  has_many :users
  has_many :care_homes
  has_many :subscriptions
  has_many :packages, through: :subscriptions

  def active_subscription
    subscriptions.exists?(company.subscriptions.active)
  end

end
