class MailLog < ApplicationRecord
  belongs_to :user, optional: true

end
