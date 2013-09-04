Mbuilder::Application.routes.draw do
  devise_for :users, controllers: {omniauth_callbacks: 'omniauth_callbacks'}

  resources :applications do
    resources :channels
    resources :triggers
    resources :messages
    get :data
  end

  match '/nuntium/receive_at' => 'nuntium#receive_at'

  root :to => 'applications#index'
end
