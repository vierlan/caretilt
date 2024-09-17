require 'rails_helper'

RSpec.describe "ActivityFeeds", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/activity_feeds/index"
      expect(response).to have_http_status(:success)
    end
  end

end
