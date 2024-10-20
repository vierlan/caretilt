class Subscription < ApplicationRecord
  belongs_to :package
  belongs_to :subscribable, polymorphic: true # Add this polymorphic association

  # check whether the subscription has a exipres_at date in the future and activate or deactivate the subscription
  #def check_status
  #  if expires_on < Time.now
  #    puts self.expires_on
  #    deactivate!
  #  else
  #    activate!
  #  end
  #  puts self.active?
  #end

  def check_status
    Rails.logger.info "Checking subscription status for #{self.subscribable}"
    Stripe.api_key = Rails.application.credentials&.stripe&.api_key
    @entity = self.subscribable
    if self.expires_on < Time.now || self.next_payment_date < Time.now
     Rails.logger.info "Subscription has expired. Fetching stripe subscription for #{@entity.name}"
     subscription = subscribable.get_active_subscription
     stripe_subscription = subscription.get_stripe_subscription(subscription.receipt_number) if subscription.present?
     Rails.logger.info "Stripe subscription found for subscription #{stripe_subscription[:latest_invoice]}"
     latest_invoice = subscription.get_lastest_stripe_invoice(subscription.receipt_number) if stripe_subscription.present?
     invoice = subscription.fetch_invoice_details(latest_invoice) if latest_invoice.present?
     exp_date = Time.at(invoice[:lines][:data][0][:period][:end]) if invoice.present?
     self.credit_log[-1][-1] = invoice.hosted_invoice_url if invoice.present?
     Rails.logger.info "Lastest invoice found for subscription #{invoice}"
      if invoice.present? && invoice[:paid] == true && exp_date > Time.now
        Rails.logger.info "Invoice paid. Updating expiry date for subscription #{self.subscribable.name}"
        update_expiry_date(exp_date)
      elsif
        invoice.present? && invoice[:paid] == false
        return false
        redirect_to invoice.hosted_invoice_url, status: 303, allow_other_host: true, notice: "Please pay your invoice to continue using the service."
      else
        return false
        AdminMailer.error("Subscription renewal error", "Subscription error for #{self.subscribable.name} #{self.subscribable.stripe_id}").deliver_now
      end
    end
  end

  def get_lastest_stripe_invoice(stripe_id)
    Stripe::Subscription.retrieve(stripe_id).latest_invoice
  end

  def fetch_invoice_details(invoice_id)
    Stripe::Invoice.retrieve(invoice_id)
  end

  def update_expiry_date(date)
    date = Time.at(date)
    self.next_payment_date = date
    self.expires_on = date
    save!
  end

  def get_stripe_subscription(stripe_id)
     Stripe::Subscription.retrieve(stripe_id)
  end

  def get_stripe_customer
    Stripe::Customer.retrieve(stripe_customer_id)
  end


  # check whether the subscription has a exipres_at date in the future
  def active?
    self.active == true
  end

  # change the active status of the subscription
  def activate!
    self.active = true
    save!
  end

  def deactivate!
    self.active = false
    save!
  end

  def set_next_payment_date
    self.next_payment_date = if self.next_payment_date.present?
                               self.next_payment_date + 1.month
                             elsif self.next_payment_date.nil?
                               self.subscribed_on + 1.month || Time.now + 1.month
                             else
                               Time.now + 1.month
                             end
    save!
  end

  #serialize :credit_log, Array
  def deduct_credit(room)
    if credits_left > 0
      self.credits_left -= 1
      self.credit_log << ["Credit used", "#{room.name} - #{room.care_home.name}", "#{Time.now}","used 1 credit", "#{credits_left}", ""]
      save!
    else
      room.update(vacant: false)
      redirect_to care_home_rooms_path(room.care_home), alert: "No credits left. Please purchase more credits."
    end
  end
end
