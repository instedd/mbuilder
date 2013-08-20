Mbuilder::Application.routes.draw do
  devise_for :users

  resources :applications do
    resources :triggers
  end

  root :to => 'applications#index'
end
