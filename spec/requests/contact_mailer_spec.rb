require 'rails_helper'

RSpec.describe "ContactMailers", type: :request do
  describe "GET /contact_email" do
    it "returns http success" do
      get "/contact_mailer/contact_email"
      expect(response).to have_http_status(:success)
    end
  end

end
