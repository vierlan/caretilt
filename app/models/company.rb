class Company < ApplicationRecord
  include Pay::Billable
  include Billable
  pay_customer stripe_attributes: :stripe_attributes

  has_many :users
  has_many :care_homes
  has_many :rooms, through: :care_homes
  has_many :subscriptions, as: :subscribable
  has_many :packages, through: :subscriptions
  has_one_attached :logo

  # after_create do
  #   Stripe.api_key = Rails.application.credentials&.stripe&.api_key
  #   Rails.logger.info("Creating Stripe customer for #{self.name}")
  #   company = Stripe::Customer.create(name: self.name, email: self.email)
  #   Rails.logger.info("Stripe customer created: #{company.name}")
  # end

  # include SharedValidAttributes #In models/concerns/shared_valid we are inclusing all phone and address validation since they shared.

  # validates :name, presence: true
  # validates :companies_house_id, presence: true, length: { is: 8 }, format: { with: /\A[A-Z0-9]{8}\z/, message: "must be 8 alphanumeric characters" }

  # checks the company has an active subscription
  def has_active_subscription?
    subscriptions.where(active: true).exists?
  end

  def get_active_subscription
    subscriptions.where(active: true).first
  end
  private
  #  check whether the subscription has a exipres_at date in the future
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
