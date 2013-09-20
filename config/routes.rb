Mbuilder::Application.routes.draw do
  devise_for :users, controllers: {omniauth_callbacks: 'omniauth_callbacks'}

  resources :applications do
    resources :channels
    resources :message_triggers
    resources :periodic_tasks
    resources :validation_triggers
    resources :messages
    get :data
  end

  match '/nuntium/receive_at' => 'nuntium#receive_at'

  root :to => 'applications#index'
end
