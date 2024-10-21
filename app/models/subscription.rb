class Subscription < ApplicationRecord
  belongs_to :package
  belongs_to :subscribable, polymorphic: true # Add this polymorphic association

   # check whether the subscription has a exipres_at date in the future and activate or deactivate the subscription
  def check_status
    if expires_on < Time.now
      puts self.expires_on
      deactivate!
    else
      activate!
    end
    puts self.active?
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
