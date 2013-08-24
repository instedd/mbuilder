Mbuilder::Application.routes.draw do
  devise_for :users, controllers: {omniauth_callbacks: 'omniauth_callbacks'}

  resources :applications do
    resources :channels
    resources :triggers
  end

  root :to => 'applications#index'
end
