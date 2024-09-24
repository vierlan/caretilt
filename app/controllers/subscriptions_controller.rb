class SubscriptionsController < ApplicationController
  before_action :set_subscriptions, only: %i[show edit update destroy]
  before_action :set_company, only: %i[new create edit update destroy]
  before_action :set_package, only: %i[new create edit update destroy]

  def index
    @subscriptions = Subscription.all
  end

  def show
  end

  def new
    @subscription = Subscription.new
  end

  def Create(attributes = {})
  end

  def edit
  end

  def update
    if @subscription.update(subscription_params)
      redirect_to company_path(@company)
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
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

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_package
    @package = Package.find(params[:package_id])
  end

  def subscription_params
    params.require(:subscription).permit(:company_id, :package_id, :start_date, :end_date)
  end


end
