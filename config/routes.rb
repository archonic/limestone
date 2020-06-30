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
      mount Flipper::UI.app(Flipper) => "/flipper", as: "flipper"
      mount Sidekiq::Web => "/sidekiq", as: "sidekiq"
    end
  end

  mount StripeEvent::Engine, at: "/stripe/webhook"

  devise_for :users,  path: "",
                      path_names: {
                        sign_in: "sign-in",
                        sign_out: "sign-out",
                        sign_up: "sign-up"
                      },
                      controllers: {
                        registrations: "users/registrations"
                      }

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
end
