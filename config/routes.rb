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

  resources :organizations, :only => [:index, :new, :create, :edit, :update, :destroy] do
    resources :hosts, :module => "organizations"
    resources :users, :module => "organizations"
    resources :metrics, :only => [:index], :module => "organizations"
    resources :applications, :only => [:index, :new, :create, :edit, :update, :destroy], :module => "organizations" do
      resource :overview, :controller => "overview", :only => [:show, :urls, :layers, :database_calls, :traces, :controllers, :hosts], :module => "applications" do
        member do
          get :urls
          get :layers
          get :database_calls
          get :hosts
          get :controllers
          get :traces
        end
      end

      resources :errors, :only => [:index, :show], :module => "applications" do
        resources :instances, :controller => "error_instances", :only => [:index, :show]
      end

      resources :metrics, :only => [:index], :module => "applications"
      resources :traces, :only => [:index, :show, :database], :module => "applications" do
        member do
          get :database
        end
      end
      resources :samples, :only => [:show], :module => "applications"
      resources :database, :controller => "database", :only => [:index], :module => "applications"
      resources :deployments, :only => [:index, :new, :create], :module => "applications"

      resources :reports, :only => [:index, :show, :new, :error, :profile], :module => "applications" do
        collection do
          get :error
          get :profile
        end
      end
    end
  end

  post "/api/listener/:protocol_version/:license_key" => "agent_listener#create"

  root :to => "dashboard#show"

end
