class ScriptTag < ApplicationRecord
  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }

  validates_presence_of :name, :code
end
