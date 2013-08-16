Mbuilder::Application.routes.draw do
  devise_for :users

  resources :applications

  root :to => 'applications#index'
end
