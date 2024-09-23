class Subscription < ApplicationRecord
  belongs_to :company
  belongs_to :package

  #serialize :credit_log, Array

end
