class Company < ApplicationRecord
  attr_accessor :address, :address2, :city, :postcode


  # include Billable
  # pay_customer stripe_attributes: :stripe_attributes


  # after_create do
  #   Rails.logger.info("Creating Stripe customer for #{self.name}")
  #   company = Stripe::Customer.create(name: self.name, email: self.email)
  #   Rails.logger.info("Stripe customer created: #{company.name}")
  # end

  # include SharedValidAttributes #In models/concerns/shared_valid we are inclusing all phone and address validation since they shared.

  # validates :name, presence: true
  # validates :companies_house_id, presence: true, length: { is: 8 }, format: { with: /\A[A-Z0-9]{8}\z/, message: "must be 8 alphanumeric characters" }

  has_many :users
  has_many :care_homes
  has_many :subscriptions
  has_many :packages, through: :subscriptions

  private

  def active_subscription
    subscriptions.exists?(company.subscriptions.active)
  end

  def stripe_attributes(pay_customer)
    {
      name: name,
      email: email,
      address: {
        line1: address1,
        line2: address2,
        city: city,
        postal_code: postcode
      },
      metadata: {
        pay_customer_id: pay_customer.id,
        user_id: id

    }
  }
  end

end
