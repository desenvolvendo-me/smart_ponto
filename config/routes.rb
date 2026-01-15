Rails.application.routes.draw do
  devise_for :users

  root 'dashboard#index', as: :authenticated_root

  resources :dashboard, only: [:index]

  resource :user_preference, only: [:edit, :update]
  resources :approvals, only: [:index] do
    member do
      patch :approve
      patch :reject
    end
  end

  # Rotas de gestão de equipe
  namespace :manager do
    resources :team_members, only: [:index], path: 'gestao-equipe' do
      member do
        patch :toggle_weekend_registration
      end
    end
  end

  resources :time_sheets, path: 'meu-ponto' do
    collection do
      get :pending_justifications
      post :approve_with_justification
      get :export
      get :export_form
      get :export_preview
      get :calendar
    end
    member do
      post :approve
      post :submit_for_approval
      post :sign
      patch :add_justification
      patch :review_justification
    end

    resources :justification_comments, path: 'comentarios', only: [:index, :create, :show, :destroy]
  end

  resources :time_entries, path: 'registros' do
    collection do
      post :quick_register
    end
  end
end
