class Stripe::CheckoutController < ApplicationController

  def pricing
    Stripe.api_key = Rails.application.credentials&.stripe&.api_key
    lookup_key = %w[ starter lite_month lite_year pro_month pro_year unlimited_month unlimited_year ]
    @prices = Stripe::Price.list({ lookup_keys: lookup_key, expand: ['data.product'] }).data.sort_by(&:unit_amount)
  end

  def show
    Stripe.api_key = Rails.application.credentials&.stripe&.api_key
    @user = current_user
    @company = current_user.company
    @company.set_payment_processor :stripe
    @company.payment_processor.customer
    Rails.logger.info("Creating Stripe customer for #{current_user.company.name} + #{@price} ")
    @checkout_session = current_user.company
      .payment_processor
      .checkout(
        mode: 'subscription',
        line_items: [{
          quantity: 1,
          price: params[:price_id]}],
        success_url: checkout_success_url,
        cancel_url: checkout_cancel_url
      )

# Log the Stripe session URL
      redirect_to @checkout_session.url, status: 303, allow_other_host: true
      Rails.logger.info "Redirecting to Stripe checkout session URL: #{@checkout_session.url}"

  end

  def add_credits
    Stripe.api_key = Rails.application.credentials&.stripe&.api_key
    @user = current_user
    @company = current_user.company
    @company.set_payment_processor :stripe
    @company.payment_processor.customer
    Rails.logger.info("Creating Stripe customer for #{current_user.company.name} + #{@price} ")
    @checkout_session = current_user.company
      .payment_processor
      .checkout(
        mode: 'payment',
        line_items: [{
          quantity: 1,
          price: params[:price_id]}],
        success_url: checkout_success_url,
        cancel_url: checkout_cancel_url
      )

# Log the Stripe session URL
      redirect_to @checkout_session.url, status: 303, allow_other_host: true
      Rails.logger.info "Redirecting to Stripe checkout session URL: #{@checkout_session.url}"

  end
  def success
    Stripe.api_key = Rails.application.credentials&.stripe&.api_key
    #retrives a json object of the purchase session
    @stripe_session = Stripe::Checkout::Session.retrieve(params[:session_id])
    line_items = Stripe::Checkout::Session.list_line_items(@stripe_session.id)
    line_items.each do |item|
      @package = Package.find_by(stripe_id: item.price.product)

      if @stripe_session.payment_status == 'paid'
        # Check if the company has an active subscription and add credits to the existing subscription
        if current_user&.company&.has_active_subscription?
          @subscription = Subscription.find_by(company_id: current_user.company.id, active: true)
          @subscription.credits_left += @package.credits
        # if not Create a new subscription instance
        else
        @subscription = Subscription.new
        @subscription.company = current_user.company
        @subscription.package = @package
        @subscription.receipt_number = @stripe_session.subscription
        @subscription.expires_on = Time.now + @package.validity.months # Assuming validity is in months
        @subscription.credits_left = @package.credits
        @subscription.active = true
        @subscription.subscribed_on = Time.now
        end
        # Log the credits purchase
        @subscription.credit_log <<  ["Purchase:", "#{@package.name}", "#{Time.now}", "added #{@package.credits} credits", "#{@subscription.credits_left}"]

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
