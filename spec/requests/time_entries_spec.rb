require 'rails_helper'

RSpec.describe "TimeEntries", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/time_entries/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/time_entries/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/time_entries/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/time_entries/create"
      expect(response).to have_http_status(:success)
    end
  end

end
