require 'rails_helper'

RSpec.describe "TeamMembers", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/team_members/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/team_members/create"
      expect(response).to have_http_status(:success)
    end
  end

end
