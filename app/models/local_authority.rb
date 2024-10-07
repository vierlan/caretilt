class LocalAuthority < ApplicationRecord
  has_many :users
  has_many :subscriptions, class_name: 'Subscription', as: :subscribable
  has_many :packages, through: :subscriptions

  include Billable
  pay_customer stripe_attributes: :stripe_attributes

  def has_active_subscription?
    subscriptions.where(status: 'active').exists?
  end

  def get_active_subscription
    subscriptions.where(status: 'active').first
  end
  private

  def stripe_attributes(pay_customer)
    {
      name: name,
      email: email,
      metadata: {
        pay_customer_id: pay_customer.id,
        local_authority_id: id,
        name: name

    }
  }
  end
end
