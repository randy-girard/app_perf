Rails.application.routes.draw do
  devise_for :users,
    :skip => [:registrations],
    :controllers => { :invitations => 'user/invitations' }
  as :user do
    get 'users/edit' => 'user/registrations#edit', :as => 'edit_user_registration'
    put ':id' => 'user/registrations#update', :as => 'registration'
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  resource :dashboard, :controller => "dashboard", :only => [:show]

  resources :applications, :only => [:index, :new, :create, :edit, :update, :destroy] do
    resources :users
    resource :overview, :controller => "overview", :only => [:show, :urls, :layers, :database_calls, :traces, :controllers, :hosts] do
      member do
        get :urls
        get :layers
        get :database_calls
        get :hosts
        get :controllers
        get :traces
      end
    end

    resources :errors, :only => [:index, :show] do
      resources :instances, :controller => "error_instances", :only => [:index, :show]
    end

    resources :metrics, :only => [:index]
    resources :traces, :only => [:index, :show, :database] do
      member do
        get :database
      end
    end
    resources :samples, :only => [:show]
    resources :database, :controller => "database", :only => [:index]
    resources :deployments, :only => [:index, :new, :create]

    resources :reports, :only => [:index, :show, :new, :error, :profile] do
      collection do
        get :error
        get :profile
      end
    end
  end

  post "/api/listener/:protocol_version/:license_key" => "agent_listener#create"

  root :to => "dashboard#show"

end
