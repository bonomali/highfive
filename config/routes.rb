Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'home#index'

  get '/auth/slack/callback', to: 'admin#slack_callback'

  resources :admin, only: [:index] do
    get :configuration, on: :collection
    get :login, on: :collection
  end

  resources :superadmin, only: [:index] do
    get :login, on: :collection
    post :login_attempt, on: :collection
  end

  post '/slack/command', to: 'slack#command'
  post '/slack/interact', to: 'slack#interact'
end
