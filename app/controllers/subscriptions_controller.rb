class SubscriptionsController < ApplicationController
  # Company and local authority is the one with stripe attatched not individual user.
  # Only super users and caretilt staff can use package, and  checkout package.
  # Only caretilt staff can edit and add package types.
  # Only superusers can view subscriptions.
  before_action :set_subscriptions, only: %i[ edit update ]
  before_action :set_entity, only: %i[new create destroy]
  before_action :set_package, only: %i[new create destroy]

  def index
    @subscriptions = Subscription.all
    @company_subsriptions = Subscription.where(subscribable_type: 'Company')
    @active_company_subscriptions = Subscription.where(csubscribable_type: 'Company', active: true)
    @la_subscriptions = Subscription.where(subscribable_type: 'LocalAuthority')
    @active_la_subscriptions = Subscription.where(subscribable_type: 'LocalAuthority', active: true)
  end

  def new
    @subscription = Subscription.new
    @local_authority = current_user.local_authority

  end

  #  path for initial subscription creation for local authorities only
  def create
    @local_authority = current_user.local_authority
    @subscription = Subscription.new
    @subscription.subscribable_id = @local_authority.id
    @subscription.subscribable_type = "LocalAuthority"
    @subscription.package_id = @package.id
    @subscription.active = false
    @subscription.expires_on = Time.now + 1.year
    @subscription.next_payment_date = Time.now + 1.year
    @subscription.subscribed_on = Time.now
    if @subscription.save!
      redirect_to local_authorities_path
    else
      render :new, status: :unprocessable_entity
    end


  end

  def edit
  end

  def update
       # Fetch the required params
       @subscription.expires_on = params[:subscription][:expires_on]
        @subscription.next_payment_date = params[:subscription][:next_payment_date]
        @subscription.subscribable_id = params[:subscription][:subscribable_id]


       action_type = params[:subscription][:action_type]
       package = Package.find_by(id: params[:subscription][:package_id]) # Find the package, or nil if not selected
       credits_added = params[:subscription][:credits_added].to_i
       time = Time.now

       # Check if the "Do not add this change to credit log" option was selected
       if action_type != 'Do not add this change to credit log'
         # Ensure each part of the log entry is in the correct format
         log_entry = [
           action_type.presence || '',         # Action Type (e.g., Purchase, Credits added, etc.) or empty string
           package&.name || '',                # Package Name or empty string
           time,                               # Time of action
           credits_added > 0 ? "added #{credits_added} credits" : '', # Description of credits added or empty string
           (@subscription.credits_left += credits_added).to_s     # Remaining credits as string (if credits_left is not updated, it will keep the current value)
         ]

         # Push the log entry to credit_log
         @subscription.credit_log << log_entry

         # Update the credits_left field if credits were added
         @subscription.credits_left += credits_added if credits_added > 0
         @subscription.package_id = params[:subscription][:package_id]
       end

    if @subscription.save!
      @subscription.check_status
      redirect_to companies_path, notice: 'Subscription was successfully updated.'
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
      @company = Company.find(params[:company_id])
    else
      @la = current_user.local_authority_id
    end
  end

  def set_package
    @package = Package.find(params[:package_id])
  end

  def subscription_params
    params.require(:subscription).permit( :expires_on, :next_payment_date, :subscribable_id, :package_id,
      :credits_added, :credits_left, :action_type)
  end

end
