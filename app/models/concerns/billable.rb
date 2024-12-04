module Billable
  extend ActiveSupport::Concern

  included do
    after_create :setup_stripe_customer
  end


  # done after signup for easy CVR metrics via Stripe UI
  def setup_stripe_customer
    Stripe.api_key = Rails.application.credentials&.stripe&.api_key
    return unless Stripe.api_key.present?

    if stripe_customer_id.present?
      begin
        # Attempt to retrieve the customer
        stripe_customer
        Rails.logger.info("Stripe customer found: #{stripe_customer_id}")
      rescue Stripe::InvalidRequestError => e
        # Log the error and create a new customer if the ID is invalid
        Rails.logger.error("Invalid Stripe customer ID (#{stripe_customer_id}): #{e.message}")
        create_stripe_customer
      end
    else
      # Create a new customer if no stripe_customer_id is present
      create_stripe_customer
    end
  end

  def stripe_customer
    Stripe::Customer.retrieve({
      id: stripe_customer_id,
      expand: ['subscriptions']
    })
  end

  def create_stripe_customer
    customer = Stripe::Customer.create({
      email: email,
      metadata: {
        external_id: id,
        name: name,
        type: self.class.name
      }
    })
    Rails.logger.info("Stripe customer created: #{customer.id}")
    update(stripe_customer_id: customer.id)
  end

  # done after user adds payment method, for easy CVR metrics inside database
  def set_stripe_subscription
    subscription_id = stripe_subscriptions&.first&.id
    paying_customer = subscription_id ? true : false
    update(stripe_subscription_id: subscription_id, paying_customer: paying_customer)
  end

  def stripe_subscriptions
    stripe_customer.subscriptions
  end

  def subscribed?
    self.has_active_subscription?
    subscription = self.get_active_subscription
    subscription.present? && subscription.active?
  end
end
