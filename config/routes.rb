Rails.application.routes.draw do

  get '/users/sign_in' => 'sessions#new', :as => :new_user_session
  post '/users/sign_in' => 'sessions#create', :as => :user_sessions
  delete '/users/sign_out' => 'sessions#destroy', :as => :user_session

  resource :dashboard, :controller => "dashboard"

  resources :applications do
    resources :transactions, :only => [:index]
    resources :raw_data, :only => [:index, :show]
    resources :reports, :only => [:index, :show, :new]
  end

  get "/agent_listener/:protocol_version/:license_key/:method" => "agent_listener#invoke_raw_method"
  post "/agent_listener/:protocol_version/:license_key/:method" => "agent_listener#invoke_raw_method"

  resources :agent_listener, :only => [:invoke_raw_method] do
    collection do
      get :invoke_raw_method
      post :invoke_raw_method
    end
  end

  root :to => "dashboard#show"

end
