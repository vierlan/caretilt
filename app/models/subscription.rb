class Subscription < ApplicationRecord
  belongs_to :package
  belongs_to :subscribable, polymorphic: true # Add this polymorphic association

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
