Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  get '/users/sign_in' => 'sessions#new', :as => :new_user_session
  post '/users/sign_in' => 'sessions#create', :as => :user_sessions
  delete '/users/sign_out' => 'sessions#destroy', :as => :user_session

  resource :dashboard, :controller => "dashboard"

  resources :applications do
    resource :overview, :controller => "overview", :only => [:show]
    resources :errors, :only => [:index, :show] do
      resources :instances, :controller => "error_instances", :only => [:index, :show]
    end
    resources :transactions, :only => [:index, :show] do
      resources :transaction_samples, :only => [:show], :as => "samples"
    end
    resources :database, :controller => "database", :only => [:index] do
      resources :samples, :only => [:index, :show], :controller => "database_samples", :as => "samples"
    end
    resources :reports, :only => [:index, :show, :new, :error] do
      collection do
        get :error
      end
    end
  end

  post "/api/listener/:protocol_version/:license_key/:method" => "agent_listener#create"

  # NewRelic RPM support
  get "/agent_listener/:protocol_version/:license_key/:method" => "agent_listener#invoke_raw_method"
  post "/agent_listener/:protocol_version/:license_key/:method" => "agent_listener#invoke_raw_method"
  resources :agent_listener, :only => [:create, :invoke_raw_method] do
    collection do
      get :invoke_raw_method
      post :invoke_raw_method
    end
  end

  root :to => "dashboard#show"

end
