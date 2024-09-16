module SharedValidAttributes
    extend ActiveSupport::Concern

    included do
      validates :phone_number,
        format: { with: /\A(\+44\s?7\d{3}|\(?07\d{3}\)?)\s?\d{3}\s?\d{3}\z|\A(\+44\s?1\d{2}|\(?01\d{2}\)?)\s?\d{3}\s?\d{4}\z|\A(\+44\s?2\d{2}|\(?02\d{2}\)?)\s?\d{3}\s?\d{4}\z|\A(\+44\s?3\d{2}|\(?03\d{2}\)?)\s?\d{3}\s?\d{4}\z|\A(\+44\s?8\d{2}|\(?08\d{2}\)?)\s?\d{3}\s?\d{4}\z/,
        message: "must be a valid UK phone number" }

      validates :postcode,
        format: { with:  /\A([A-Z]{1,2}\d{1,2}[A-Z]?) ?\d[A-Z]{2}\z/i,
        message: "must be a valid UK postcode" }
       
    end

  end
