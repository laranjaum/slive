Rails.application.routes.draw do
  # Sidekiq Web UI, only for admins.
  require "sidekiq/web"
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  ActiveAdmin.routes(self)

  devise_for :users,
    controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  resources :users, only: [:edit , :show, :update, :index] do
    resources :dashboards, only: [:index]
    get "created_events", to: "dashboards#created_events", as: "created_events"
    get "participated_events", to: "dashboards#participated_events", as: "participated_events"
  end

  resources :events do
    resources :live, only: [:index]
    get "/participants", to: "events#event_participants", as: "participants"
    post "remove_user_from_event/:id", to: "events#remove_user_from_event", as: "remove_user_from_event"
    resources :questions, only: [:index, :show, :new, :create]

    resources :presentations


    post "livemessage", to: "livemessages#create"
    resources :livemessages, only: [:index]

    resources :surveys, only: [:index, :show, :new, :create] do
      resources :votes, only: [:index, :show, :new, :create]
    end

  end

  resources :questions, only: [] do
    resources :answers, only: [:new, :create, :edit, :update]
  end

  post "register", to: "events#register_users"
  root to: 'pages#home'


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
