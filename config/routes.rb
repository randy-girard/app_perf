Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  scope '/system', :module => 'system_metrics' do
    get 'metrics/admin' => 'metrics#admin', :as => 'system_metrics_admin'
    get 'metrics/category/:category' => 'metrics#category', :as => 'system_metrics_category'
    resources :metrics, :only => [:index, :show, :destroy]
  end

  get '/users/sign_in' => 'sessions#new', :as => :new_user_session
  post '/users/sign_in' => 'sessions#create', :as => :user_sessions
  delete '/users/sign_out' => 'sessions#destroy', :as => :user_session

  resource :dashboard, :controller => "dashboard"

  resources :applications do
    resources :errors, :only => [:index, :show]
    resources :transactions, :only => [:index]
    resources :raw_data, :only => [:index, :show]
    resources :reports, :only => [:index, :show, :new, :error] do
      collection do
        get :error
      end
    end
  end

  post "/api/listener/:protocol_version/:license_key/:method" => "agent_listener#create"

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
