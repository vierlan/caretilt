class SubscriptionsController < ApplicationController
  # Company and local authority is the one with stripe attatched not individual user.
  # Only super users and caretilt staff can use package, and  checkout package.
  # Only caretilt staff can edit and add package types.
  # Only superusers can view subscriptions.
  before_action :set_subscriptions, only: %i[edit update]
  before_action :set_entity, only: %i[new create]
  before_action :set_package, only: %i[new create destroy]

  def new
    @subscription = Subscription.new
  end

  #  path for initial subscription creation for local authorities only
  def create
    Stripe.api_key = Rails.application.credentials&.stripe&.api_key
    local_authority = current_user.local_authority
    @package = Package.find(params[:package_id])
    # Find the stripe customer on payment processor
    @valid_customer = local_authority.stripe_customer_id.present? && local_authority.stripe_customer_valid?
    Rails.logger.info("Valid customer: #{@valid_customer}")
    if !@valid_customer
      Rails.logger.info("Creating Stripe customer for #{current_user.local_authority.name} if !@vaild_customer")
      @customer = local_authority.create_stripe_customer
    elsif @valid_customer.respond_to?(:deleted) && @valid_customer.deleted
      Rails.logger.info("Creating Stripe customer for #{current_user.local_authority.name} if @valid_customer.deleted")
      @customer = local_authority.create_stripe_customer
    else
      Rails.logger.info("Retrieving Stripe customer for #{current_user.local_authority.name}")
      @customer = @valid_customer
    end
    @subscription = Subscription.new(
      subscribable: @local_authority,
      subscribable_id: @local_authority.id,
      package_id: @package.id,
      active: false,
      expires_on: Time.now + 1.year,
      next_payment_date: Time.now,
      subscribed_on: Time.now,
      number_of_payments: 1
    )
    if @subscription.save!
      invoice_data = create_stripe_subscription(@local_authority, @package)
      invoice_id = invoice_data.id
      invoice_url = invoice_data.hosted_invoice_url

      # Log the credits purchase
      @subscription.credit_log << ["#{@local_authority.name}", "#{@package.name}", "#{Time.now}", "#{invoice_id}", "#{invoice_url}"]
      @subscription.receipt_number = invoice_url.to_s
      @subscription.save!
      @local_authority.update(stripe_subscription_id: invoice_data.subscription)

      redirect_to packages_path, notice: 'Subscription was successfully updated.'
      # redirect_to subscription_invoice_path(@subscription), notice: "Subscription created successfully. Please check your invoice for payment instructions."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # Fetch the required params
    @subscription = Subscription.find(params[:id])
    @subscription.expires_on = params[:subscription][:expires_on]
    @subscription.next_payment_date = params[:subscription][:next_payment_date]
    @subscription.subscribable_id = params[:subscription][:subscribable_id]
    @action_type = params[:subscription][:action_type]
    @package = @subscription.package || ''# Find the package, or nil if not selected
    @credits_added = params[:subscription][:credits_added].to_i || 0
    @time = Time.now
    if @subscription.subscribable_type == 'Company'
    @credits_left = @subscription.credits_left + @credits_added
    @subscription.credits_left = @credits_left
    end
    # @subscription.package_id = params[:subscription][:package_id]
    # Check if the "Do not add this change to credit log" option was selected

    if @subscription.save!
      @subscription.check_status
      if @action_type != 'Do not add this change to credit log'
        # Ensure each part of the log entry is in the correct format
        @log_entry = [
          @action_type.presence || '',         # Action Type (e.g., Purchase, Credits added, etc.) or empty string
          @package&.name || '',                # Package Name or empty string
          @time,                               # Time of action
          @credits_added > 0 ? "added #{@credits_added} credits" : "deducted #{@credits_added} credits", # Description of credits added or empty string
          @credits_left # Remaining credits as string (if credits_left is not updated, it will keep the current value)
        ]
        Rails.logger.info "Log entry: #{@log_entry}"
        # Push the log entry to credit_log
        @subscription.credit_log << @log_entry
        @subscription.save!
      end
      redirect_to package_path(@subscription), notice: 'Subscription was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def deactivate_expired
    # Queue the task to run the deactivation for expired subscriptions
    Subscription.all.each do |subscription|
      subscription.check_status
    end

    # Redirect to the subscriptions page with a success message
    redirect_to companies_path, notice: 'Deactivation task has been triggered for expired subscriptions.'
  end

  def payment_received
    # Fetch the required params
    @subscription = Subscription.find(params[:id])
    @sunscription.update(active: true, next_payment_date: Time.now + 1.year, expires_on: Time.now + 1.year)
    redirect_to packages_path, notice: 'Payment received. Subscription has been activated.'
  end

  private

  def add_credits(package)
    @package = package
    @active_subscription = Subscription.find_by(company_id: current_user.company.id, active: true)
    if current_user&.company&.has_active_subscription?
      @active_subscription.update(credits: @active_subscription.credits + @package.credits)
    end
  end

  def set_subscriptions
    @subscription = Subscription.find(params[:id])
  end

  def set_entity
    if current_user.company.present?
      @company = current_user.company || Company.find(params[:company_id])
    else
      @local_authority = current_user.local_authority || LocalAuthority.find(params[:local_authority_id])
    end
  end

  def set_package
    @package = Package.find(params[:package_id])
  end

  def subscription_params
    params.require(:subscription).permit(:expires_on, :next_payment_date, :subscribable_id, :package_id,
                                         :credits_added, :credits_left, :action_type)
  end

  def create_stripe_subscription(local_authority, package)
    # Define the subscription items (using the package's Stripe price)
    subscription_items = [{
      price: package.stripe_price_id, # Assume `stripe_price_id` is set on the package model
      quantity: 1
    }]
    @valid_customer = local_authority.stripe_customer_id.present? && local_authority.stripe_customer_valid?
    Rails.logger.info("Valid customer: #{@valid_customer}")
    if !@valid_customer
      Rails.logger.info("Creating Stripe customer for #{current_user.local_authority.name} if !@vaild_customer")
      @customer = local_authority.create_stripe_customer
    elsif @valid_customer.respond_to?(:deleted) && @valid_customer.deleted
      Rails.logger.info("Creating Stripe customer for #{current_user.local_authority.name} if @valid_customer.deleted")
      @customer = local_authority.create_stripe_customer
    else
      Rails.logger.info("Retrieving Stripe customer for #{current_user.local_authority.name}")
      @customer = @valid_customer
    end
    stripe_subscription = Stripe::Subscription.create({
      customer: @customer.id,
      items: subscription_items,
      payment_behavior: 'default_incomplete', # This prevents immediate payment
      expand: ['latest_invoice.payment_intent'],
      metadata: {
        subscribable_id: local_authority.id,
        subscribable_type: "LocalAuthority",
        package_id: package.id,
        name: "#{local_authority.name} - #{package.name}"
      }
    })
    invoice = stripe_subscription.latest_invoice
    # url = invoice.hosted_invoice_url
    # pdf = invoice.invoice_pdf
    invoice_data = invoice
    Rails.logger.info "Created Stripe subscription with ID: #{stripe_subscription}"

    # Get the Stripe invoice URL for the subscription
    invoice_data
  end

end
