class PackagesController < ApplicationController
  before_action :set_packages, only: %i[show edit update destroy]
  def index
    @packages = Package.all

  end

  def show
  end

  def new
    @package = Package.new
  end

  def create
    @package = Package.new(package_params)
    Stripe.api_key = Rails.application.credentials.stripe[:api_key]
    if @package.save
      service = StripePackage.new(@package)
      service.create_package
      redirect_to packages_index_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def create_stripe_checkout_session(package)
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
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
                              metadata: {

                                package_id: @package.id,

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

  def set_company
    @company = Company.find(params[:id])
  end

  def package_params
    params.require(:package).permit(:name, :description, :credits, :price, :validity, :stripe_price_id, :stripe_id, data: {})
  end


end
