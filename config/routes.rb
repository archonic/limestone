# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  # Administrate
  constraints CanAccessAdmin do
    namespace :admin do
      root controller: "users", action: :index
      resources :users do
        post :impersonate, on: :member
      end
      get :stop_impersonating, to: :stop_impersonating, controller: "users"
      resources :invoices
      mount Flipper::UI.app(Flipper) => '/flipper', as: 'flipper'
      mount Sidekiq::Web => '/sidekiq', as: 'sidekiq'
    end
  end

  mount StripeEvent::Engine, at: "/stripe/webhook"

  devise_for :users, path: "",
                     path_names: { sign_in: "login", sign_out: "logout", registration: "profile" },
                     controllers: { registrations: "users/registrations" } # sessions: "users/sessions", passwords: "users/passwords"

  unauthenticated :user do
    devise_scope :user do
      root to: "pages#features"
    end
  end

  # Signed out (marketing) pages
  get "pricing", to: "pages#pricing"
  get "about", to: "pages#about"
  get "cancelled", to: "pages#cancelled"

  # Signed in pages
  authenticated :user do
    root to: "dashboard#show", as: "dashboard"
    get "pro", to: "pages#pro"
  end

  # Avatars
  patch "avatars", to: "avatars#update"
  delete "avatar", to: "avatars#destroy"

  # Subscription stuff
  get "billing", to: "subscriptions#show"
  get "subscribe", to: "subscriptions#new"
  patch "subscriptions", to: "subscriptions#update"
  get "invoices", to: "invoices#index"
  get "invoices/:id", to: "invoices#show", as: "invoice"
end
