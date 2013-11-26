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
    resources :tables, except: [:index, :new, :create, :edit, :update, :destroy] do
      resources :records, only: [:edit, :update, :destroy]
    end
  end

  authenticate :user do
    mount Pigeon::Engine => '/pigeon'
  end

  match '/nuntium/receive_at' => 'nuntium#receive_at'

  match '/resource_map/collections.json' => 'resource_map#collections'
  match '/resource_map/collections/:id/fields.json' => 'resource_map#collection_fields'

  mount Listings::Engine => '/listings'

  root :to => 'home#index'
end
