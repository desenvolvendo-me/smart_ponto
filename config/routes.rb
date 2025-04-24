Rails.application.routes.draw do
  devise_for :users

  root "time_sheets#index"

  resources :time_sheets, path: 'meu-ponto' do
    collection do
      get :pending_justifications
      post :approve_with_justification
      get :export
      get :export_form
      get :calendar
    end
    member do
      post :approve
      post :submit_for_approval
      post :sign
      patch :add_justification
      patch :review_justification
    end
  end

  resources :time_entries, path: 'registros' do
    collection do
      post :quick_register
    end
  end
end
