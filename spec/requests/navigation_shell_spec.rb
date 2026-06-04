# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Navigation shell", type: :request do
  describe "GET /dashboard" do
    it "renders the global menu for a collaborator" do
      user = create(:user, role: "colaborador")
      sign_in user, scope: :user

      get dashboard_index_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Dashboard")
      expect(response.body).to include("Meu ponto")
      expect(response.body).not_to include("Calendário")
      expect(response.body).not_to include("Exportar Registros")
      expect(response.body).not_to include("Aprovações")
      expect(response.body).not_to include("Gestão da equipe")
    end

    it "shows management links only for managers" do
      user = create(:user, role: "gestor")
      sign_in user, scope: :user

      get dashboard_index_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Aprovações")
      expect(response.body).to include("Gestão da equipe")
    end

    it "does not embed sidebar control scripts in the layout" do
      user = create(:user)
      sign_in user, scope: :user

      get dashboard_index_path

      expect(response.body).not_to include("toggleDesktopSidebar")
      expect(response.body).not_to include("document.addEventListener('turbo:load'")
    end
  end
end
