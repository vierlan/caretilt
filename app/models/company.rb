class Company < ApplicationRecord
  attr_accessor :address, :address2, :city, :postcode

  has_many :users
  has_many :care_homes

end
