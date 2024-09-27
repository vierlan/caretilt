class BillingPortalSessionsController < ApplicationController

  def create
    Stripe.api_key = Rails.application.credentials&.stripe&.api_key
    portal_session = Stripe::BillingPortal::Session.create({
      customer: current_user.company.stripe_customer_id,
      return_url: dashboard_index_url
    })
    redirect_to portal_session.url, status: 303, allow_other_host: true
  end
end