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

  #serialize :credit_log, Array
  def deduct_credit(room)
    if credits_left > 0
      self.credits_left -= 1
      self.credit_log << ["Credit used", "#{room.name} - #{room.care_home.name}", "#{Time.now}","used 1 credit", "#{credits_left}"]
      save!
    else
      Rails.logger.warn "Attempted to deduct credit, but no credits left."
    end
  end
end
