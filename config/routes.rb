Mbuilder::Application.routes.draw do
  devise_for :users, controllers: {omniauth_callbacks: 'omniauth_callbacks'}
  guisso_for :user

  resources :applications do
    resources :channels
    resources :message_triggers
    resources :periodic_tasks
    resources :validation_triggers
    resources :messages
    get :data
  end

  authenticate :user do
    mount Pigeon::Engine => '/pigeon'
  end

  match '/nuntium/receive_at' => 'nuntium#receive_at'

  match '/resource_map/collections.json' => 'resource_map#collections'

  root :to => 'home#index'
end
