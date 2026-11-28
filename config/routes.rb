Rails.application.routes.draw do
  root "home#show"

  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[ new create ]

  resources :titles, only: %i[ index show ]
  # The collectors directory (index) is hidden for now; add :index back to restore it.
  resources :collectors, only: :show, param: :username
  resources :collection_items, only: %i[ create update destroy ]

  namespace :admin do
    root "dashboard#show"

    resources :titles, except: :show do
      resources :faces, only: :destroy, module: :titles, param: :face
    end
    resources :users, only: %i[ index edit update destroy ]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
