class StripePackage

  def initialize(package)
    @package = package
  end

   # When caretilt wants to create a new package, it will call this method
   #  This is all the data sent to stripe to create a new package
   # Stripe API responds with the ids of the product, plan and price and the @package is updated with these ids

  # one-off purchase of credits only, must have existing subscription
  def create_add_credits_package
    return if @package.stripe_id.present?
    Stripe.api_key = Rails.application.credentials&.stripe&.api_key
    stripe_product = Stripe::Product.create(
      name: @package.name,
      description: @package.description,
      active: true,
      metadata: {
        package_id: @package.id,
        credits: @package.credits,
      }
    )
    stripe_price = Stripe::Price.create(
      currency: 'gbp',
      unit_amount: (@package.price * 100).to_i,  # Ensure unit amount is an integer
      product: stripe_product.id,
    )
    @package.update(
      stripe_id: stripe_product.id,
      data: stripe_product.to_json,
      stripe_price_id: stripe_price.id
    )
  end



  def create_package
    return if @package.stripe_id.present?
    Stripe.api_key = Rails.application.credentials&.stripe&.api_key
    stripe_product = Stripe::Product.create(
      name: @package.name,
      description: @package.description,
      active: true,
      metadata: {
        package_id: @package.id,
        credits: @package.credits,
        validity: @package.validity,
        created: Date.today.to_time.to_i,
        subscription_type: @package.subscription_type
      }
    )

    # Create Stripe recurring price (replaces Plan)
    stripe_price = Stripe::Price.create(
      currency: 'gbp',
      unit_amount: (@package.price * 100).to_i,  # Ensure unit amount is an integer
      recurring: {
        interval: 'month', # Adjust as needed (e.g., 'year' for yearly subscriptions)
        interval_count: @package.validity   # How often the subscription should recur (e.g., every month)
      },
      product: stripe_product.id
    )

      # Update the package with Stripe product and price IDs

    @package.update(
      stripe_id: stripe_product.id,
      data: stripe_product.to_json,
      stripe_price_id: stripe_price.id
    )

  end

  def update_package
    return if @package.stripe_id.blank?
    Stripe.api_key = Rails.application.credentials&.stripe&.api_key
    stripe_product = Stripe::Product.retrieve(@package.stripe_id)
    stripe_product.name = @package.package_name
    stripe_product.description = @package.package_description
    stripe_product.save
    stripe_price = Stripe::Price.retrieve(@package.stripe_price_id)
    stripe_price.unit_amount_decimal = @package.package_price * 100
    stripe_price.save
    @package.update(
      data: stripe_product.to_json
    )
  end
end
