class LocalAuthority < ApplicationRecord
  has_many :users
  has_many :la_licences
end
