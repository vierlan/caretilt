Stripe.api_key = Rails.application.credentials&.stripe&.api_key
if Stripe.api_key.nil?
  Rails.logger.error "Stripe API key is not set. Please check your credentials."
else
  Rails.logger.info "Stripe API key is set successfully."
end
