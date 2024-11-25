class PackagesController < ApplicationController

  # Company and local authority is the one with stripe attatched not individual user.
  # Only super users and caretilt staff can use package, and  checkout package.
  # Only caretilt staff can edit and add package types.
  # Only superusers can view subscriptions.
  before_action :set_package, only: %i[edit update destroy]

  def index
    @packages = policy_scope(Package).all
    @subscription_packages = Package.where.not(validity: 0)
    @credit_packages = Package.where(validity: 0)
    case current_user.role
    when 'caretilt_staff', 'caretilt_master_user'
      @company = current_user.company
    when 'care_provider_super_user'
      @company = current_user.company
      @packages = @packages.where(subscription_type: 'company_subscription')
      @packages = @packages.where.not(validity: 0)
      if current_user&.company&.has_active_subscription?
        @active_subscription = current_user.company.get_active_subscription
        @logs = @active_subscription&.credit_log || []
        @active_package = Package.find(@active_subscription.package_id)
        @packages = Package.where(validity: 0)
        last_credit_log = @subscription&.credit_log&.last if @active_subscription.credit_log.present?
        @invoice_url = @active_subscription&.receipt_number || (last_credit_log.present? ? last_credit_log.last : nil)

      end
    when 'la_super_user'
      @local_authority = current_user.local_authority
      @packages = @packages.where(subscription_type: 1)
      @subscription = Subscription.new unless @local_authority.subscriptions.present?
      if current_user&.local_authority&.subscriptions&.present?
        @active_subscription = current_user.local_authority.get_active_subscription || current_user.local_authority.subscriptions.last
        @active_package = Package.find(@active_subscription.package_id)
        @packages = @packages.where(subscription_type: 'local_authority_subscription')
        last_credit_log = @subscription&.credit_log&.last if @active_subscription.credit_log.present?
        @invoice_url = @active_subscription&.receipt_number || (last_credit_log.present? ? last_credit_log.last : nil)
      end
    end
  end

  def show
    @company = Company.find(params[:id])
    @active_subscription = @company.get_active_subscription
    @active_package = Package.find(@active_subscription.package_id)
  end

  def new
    @package = Package.new
    authorize @package
  end

  # creating a package also creates a new instance in StripePackage model which will update Stripe with the new package
  def create
    @package = Package.new(package_params)
    Stripe.api_key = Rails.application.credentials&.stripe&.api_key
    if @package.save
      service = StripePackage.new(@package)
      if @package.validity == 0
        service.create_add_credits_package
      else
        service.create_package
      end
      redirect_to packages_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  #  I don't think we are using this one, check the one in checkouts_controller#show
  def create_stripe_checkout_session(package)
    Stripe.api_key = Rails.application.credentials&.stripe&.api_key
    @package = package
    @package_id = @package.id
    @stripe_price_id = @package.stripe_price_id
    Rails.logger.info "Creating Stripe checkout session with price ID: #{@stripe_price_id}, package ID: #{@package_id}"
    begin
      @checkout_session = Stripe::Checkout::Session.create({
        payment_method_types: ['card'],
        mode: 'subscription',
        line_items: [{
          price: @stripe_price_id,
          quantity: 1
        }],
        allow_promotion_codes: true,
        customer: current_user.company.stripe_id,
        metadata: {

          package_id: @package.id

        },
        success_url: checkout_success_url,
        cancel_url: checkout_cancel_url
      })
    rescue Stripe::InvalidRequestError => e
      Rails.logger.error "Stripe error: #{e.message}"
      flash[:error] = "There was a problem creating the Stripe checkout session: #{e.message}"
      redirect_to new_package_path
    end
  end

  def edit
  end

  def update
    if @package.update(package_params)
      redirect_to packages_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  end

  private

  def set_package
    @package = Package.find(params[:id])
  end

  def set_company
    @company = Company.find(params[:id])
  end

  def package_params
    params.require(:package).permit(:name, :description, :credits, :price, :validity, :subscription_type, :stripe_price_id, :stripe_id, features: [], data: {})
  end
end
