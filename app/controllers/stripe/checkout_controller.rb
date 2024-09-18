class Stripe::CheckoutController < ApplicationController

  def pricing
    lookup_key = %w[ starter lite_month lite_year pro_month pro_year unlimited_month unlimited_year ]
    @prices = Stripe::Price.list({ lookup_keys: lookup_key, expand: ['data.product'] }).data.sort_by(&:unit_amount)
  end

  def checkout

    begin
      session = Stripe::Checkout::Session.create({
        mode: 'subscription',
        payment_method_types: ['card'],
        line_items: [{
          quantity: 1,
          price: params[:price_id]
        }],
        success_url: stripe_checkout_success_path,
        cancel_url: stripe_checkout_cancel_path
      })

    rescue StandardError => e
      render json: { error: { message: e.message } }, status: :bad_request

    end
    #redirect_to session.url, allow_other_host: true

  end

  def success
    session = Stripe::Checkout::Session.retrieve(params[:session_id])

    if session.payment_status == 'paid'
      current_user.set_stripe_subscription
      redirect_to dashboard_index_path, notice: 'Your account is now active!'
    else
      redirect_to subscribe_index_path, alert: "Please subscribe to continue."
    end
  end

  def cancel
    redirect_to subscribe_index_path, alert: "Subscription canceled."

  end

end
