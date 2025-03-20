require 'rails_helper'

RSpec.describe "TimeSheets", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/time_sheets/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/time_sheets/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /export" do
    it "returns http success" do
      get "/time_sheets/export"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /approve" do
    it "returns http success" do
      get "/time_sheets/approve"
      expect(response).to have_http_status(:success)
    end
  end

end
