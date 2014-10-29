Mbuilder::Application.routes.draw do
  get "logs/index"

  devise_for :users, controllers: {omniauth_callbacks: 'omniauth_callbacks'}
  guisso_for :user

  resources :applications do
    resources :channels
    resources :message_triggers
    resources :periodic_tasks
    resources :validation_triggers
    resources :external_triggers
    resources :messages, only: :create
    resources :logs, only: :index

    get :data
    resources :tables, only: [] do
      resources :records, except: [:index, :show]
    end

    get :export
    post :import

    get :request_api_token
  end

  get '/api/actions' => 'api#actions'
  get '/api/applications/:id/tables' => 'api#index',as: :api_index
  get '/api/applications/:id/tables/:table_id(.:format)' => 'api#show', as: :api_show, defaults: { format: 'json' }

  post '/external/application/:application_id/trigger/:trigger_name(.:format)' => 'external_triggers#run', as: :run_external_trigger, defaults: { format: 'json' }

  authenticate :user do
    mount Pigeon::Engine => '/pigeon'
  end

  match '/nuntium/receive_at' => 'nuntium#receive_at'

  match '/resource_map/collections.json' => 'resource_map#collections'
  match '/resource_map/collections/:id/fields.json' => 'resource_map#collection_fields'

  mount Listings::Engine => '/listings'

  root :to => 'home#index'
end
