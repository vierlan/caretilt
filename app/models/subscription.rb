class Subscription < ApplicationRecord
  belongs_to :company
  belongs_to :package

  #serialize :credit_log, Array
  def deduct_credit(room)
    if credits_left > 0
      self.credits_left -= 1
      self.credit_log << ["1 credit deducted_on: #{Time.now}, on #{room.name} @ #{room.care_home.name},  total_credits: #{credits_left}"]
      save!
    else
      Rails.logger.warn "Attempted to deduct credit, but no credits left."
    end
  end
end
