class Stripe::CheckoutController < ApplicationController

  def pricing
    authorize :checkout, :pricing?
    Stripe.api_key = Rails.application.credentials&.stripe&.api_key
    lookup_key = %w[ starter lite_month lite_year pro_month pro_year unlimited_month unlimited_year ]
    @prices = Stripe::Price.list({ lookup_keys: lookup_key, expand: ['data.product'] }).data.sort_by(&:unit_amount)
  end

  #creates a stripe checkout session for company subscriptions
  def show
    Stripe.api_key = Rails.application.credentials&.stripe&.api_key
    @user = current_user
    @company = current_user.company
    @package = Package.find(params[:package])
    Rails.logger.info("Creating Stripe customer for #{current_user.company.name} + #{@price} ")
    @checkout_session = Stripe::Checkout::Session.create(
      mode: @package.description.include?('non-renewable') ? 'payment' : 'subscription',
      line_items: [{
        quantity: 1,
        price: @package.stripe_price_id
      }],
      customer: current_user.company.stripe_customer_id,
      metadata: {
        user: current_user.full_name,
        company_id: current_user.company.id,
        company_name: current_user.company.name,
        package_name: @package.name
      },
      payment_method_types: ['card'], # Add bank payment methods

      success_url: "#{checkout_success_url}?session_id={CHECKOUT_SESSION_ID} ",
      cancel_url: checkout_cancel_url
      )
      @session_id = @checkout_session.id
      Rails.logger.info("Stripe checkout session created: #{@session_id} #{@checkout_session}")
# Log the Stripe session URL
      redirect_to @checkout_session.url, status: 303, allow_other_host: true
      Rails.logger.info "Redirecting to Stripe checkout session URL: #{@checkout_session.url}"
  end

  def get_stripe_events
      Stripe.api_key = Rails.application.credentials&.stripe&.api_key
      # Fetch the latest events
      @events = Stripe::Event.list({limit: 20})
      # You can render this or return as needed
  end


  def add_credits
    Stripe.api_key = Rails.application.credentials&.stripe&.api_key
    @user = current_user
    @company = current_user.company

    Rails.logger.info("Creating Stripe customer for #{current_user.company.name} + #{@price} ")
    @checkout_session = Stripe::Checkout::Session.create(
        payment_method_types: ['card'],
        mode: 'payment',
        customer: current_user.company.stripe_customer_id,
        line_items: [{
          quantity: 1,
          price: params[:price_id]}],
          success_url: "#{checkout_success_url}?session_id={CHECKOUT_SESSION_ID} ",
          cancel_url: checkout_cancel_url
      )

# Log the Stripe session URL
      redirect_to @checkout_session.url, status: 303, allow_other_host: true
      Rails.logger.info "Redirecting to Stripe checkout session URL: #{@checkout_session.url}"

  end


  def success
    Stripe.api_key = Rails.application.credentials&.stripe&.api_key

    # Retrieve the Stripe session
    @stripe_session = Stripe::Checkout::Session.retrieve(params[:session_id])
    line_items = Stripe::Checkout::Session.list_line_items(@stripe_session.id)

    # Iterate through line items to find the associated package
    line_items.each do |item|
      @package = Package.find_by(stripe_id: item.price.product)

      # Only proceed if the payment status is 'paid'
      if @stripe_session.payment_status == 'paid'
        subscribable_entity = current_user&.company || current_user&.local_authority

        # Check if the user has an active subscription and add credits to the existing subscription
        @subscription = Subscription.find_by(subscribable: subscribable_entity, active: true)

        if @subscription.present?
          @subscription.credits_left += @package.credits
        else
          # Create a new subscription if none exists
          @subscription = Subscription.new(
            subscribable: subscribable_entity,
            package: @package,
            receipt_number: @stripe_session.subscription,
            expires_on: Time.now + @package.validity.months,
            credits_left: @package.credits,
            next_payment_date: Time.now + @package.validity.months,
            active: true,
            subscribed_on: Time.now
          )
        end

        # Log the credits purchase
        @subscription.credit_log << ["Purchase:", "#{@package.name}", "#{Time.now}", "added #{@package.credits} credits", "#{@subscription.credits_left}"]
        subscribable_entity.update(stripe_subscription_id: @stripe_session.subscription, paying_customer: true)
        # Save the subscription
        @subscription.save!
      else
        redirect_to subscribe_index_path, alert: "Please subscribe to continue."
      end
    end

    redirect_to dashboard_index_path, notice: 'Subscription successful.'
  end


  def cancel
    redirect_to subscribe_index_path, alert: "Subscription canceled."

  end

end
