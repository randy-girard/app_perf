Rails.application.routes.draw do
  devise_for :users,
    :skip => [:registrations],
    :controllers => { :invitations => 'user/invitations' }
  as :user do
    get 'users/edit' => 'user/registrations#edit', :as => 'edit_user_registration'
    put ':id' => 'user/registrations#update', :as => 'registration'
  end

  resource :dashboard, :controller => "dashboard", :only => [:show]
  resources :users

  resources :hosts
  resources :metrics, :only => [:index, :show] do
    member do
      get "/(:id)" => "metrics#show", :id => /.*/
    end
  end

  resources :applications, :only => [:index, :new, :create, :edit, :update, :destroy] do
    resource :overview, :controller => "overview", :only => [:show]

    resources :errors, :only => [:index, :show] do
      resources :instances, :controller => "error_instances", :only => [:index, :show]
    end

    resources :metrics, :only => [:index]
    resources :traces, :only => [:index, :show, :database] do
      member do
        get :database
      end
    end
    resources :spans, :only => [:show]
    resources :database, :controller => "database", :only => [:index]
    resources :deployments, :only => [:index, :new, :create]

    resources :reports, :only => [:new, :error, :profile] do
      collection do
        get :error
        get :profile
      end
    end
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  mount API::Base, at: "/api"

  if defined?(Enterprise)
    mount Enterprise::Engine => "/"
  elsif defined?(Hosted)
    mount Hosted::Engine => "/"
  end

  root :to => "dashboard#show"
end
