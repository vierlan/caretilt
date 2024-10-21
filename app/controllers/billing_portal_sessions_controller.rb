class BillingPortalSessionsController < ApplicationController

  def create
    Stripe.api_key = Rails.application.credentials&.stripe&.api_key
    portal_session = Stripe::BillingPortal::Session.create({
      customer: current_user.company.stripe_customer_id,
      return_url: dashboard_index_url
    })
    redirect_to portal_session.url, status: 303, allow_other_host: true
  end

  def invoice
    Stripe.api_key = Rails.application.credentials&.stripe&.api_key
    @subscription = Subscription.find(params[:id])
    last_credit_log = @subscription.credit_log.last
    @invoice_url = last_credit_log.present? ? last_credit_log.last : nil
  end
end

