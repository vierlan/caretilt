class Stripe::WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    webhook_secret = Rails.application.credentials.stripe[:webhook_secret]
    payload = request.body.read

    begin
      event = Stripe::Event.construct_from(
        JSON.parse(payload, symbolize_names: true)
      )
    rescue JSON::ParserError => e
      Rails.logger.error("JSON::ParserError: #{e.message}")
      render json: { message: e.message }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error("Stripe::SignatureVerificationError: #{e.message}")
      render json: { message: e.message }, status: 400
      return
    end

    if webhook_secret
      signature = request.env['HTTP_STRIPE_SIGNATURE']
      begin
        event = Stripe::Webhook.construct_event(
          payload, signature, webhook_secret
        )
      rescue Stripe::SignatureVerificationError => e
        Rails.logger.error("Stripe::SignatureVerificationError: #{e.message}")
        render json: { message: e.message }, status: 400
        return
      end
    end

    event_type = event['type']
    data = event['data']
    data_object = data['object']

    begin
      case event_type
      when 'customer.created'
        Rails.logger.info("Customer created: #{event_type}")
        customer = data_object
        company = Company.find_by(email: customer.email)
        if company
          company.update(stripe_customer_id: customer.id)
        else
          Rails.logger.error("Company not found for email: #{customer.email}")
        end
      when 'customer.subscription.deleted'
        Rails.logger.info("Subscription canceled: #{event.id}")
      when 'customer.subscription.updated'
        Rails.logger.info("Subscription updated: #{event.id}")
      when 'customer.subscription.created'
        Rails.logger.info("Subscription created: #{event.id}")
      when 'customer.subscription.trial_will_end'
        Rails.logger.info("Subscription trial will end: #{event.id}")
      when 'entitlements.active_entitlement_summary.updated'
        Rails.logger.info("Active entitlement summary updated: #{event.id}")
      else
        Rails.logger.info("Unhandled event type: #{event_type}")
      end
    rescue => e
      Rails.logger.error("Exception during event processing: #{e.message}")
      render json: { message: e.message }, status: 400
      return
    end

    render json: { message: 'success' }
  end
end
