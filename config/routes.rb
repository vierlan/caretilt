Rails.application.routes.draw do


  root 'pages#home'
  ActiveAdmin.routes(self)


  #debug session route
  #get '/session', to: 'activity_feeds#index'
  get 'verify/:id', to: 'users#verify', as: 'verify'
  patch 'verify/:id', to: 'users#verify_user'
  get '/team_members/:id/verify', to: 'team_members#verify_member', as: 'verify_member'
  patch '/team_members/:id/verify', to: 'team_members#verify_member_update'
  get '/checkout', to: 'stripe/checkout#show', as: 'checkout'
  #post '/checkout', to: 'stripe/checkout#checkout'
  get '/checkout/add_credits', to: 'stripe/checkout#add_credits'
  get '/checkout/pricing', to: 'stripe/checkout#pricing'
  get '/checkout/success', to: 'stripe/checkout#success'
  get '/checkout/cancel', to: 'stripe/checkout#cancel'

  pages = %w[
    privacy terms about contact home home2 home3 home4 guides calculator faq pricing search quiz test test2
  ]
  get 'activity_feeds', to: 'activity_feeds#index'

  resources :companies do
    member do
      get 'add_team_member', to: 'team_members#new', as: 'company_member' # Updated to use 'new' action
      get 'team', to: 'team_members#index'
      post 'add_team_member', to: 'team_members#create'
      get 'account', to: 'dashboard#account'
      get 'activity_feeds', to: 'activity_feeds#index'
    end
    resources :care_homes, only: %i[new create] do
      collection do
        get 'all'
      end
    end
  end

  resources :local_authority do
    member do
      get 'add_team_member', to: 'team_members#new', as: 'la_member'
      post 'add_team_member', to: 'team_members#create'
      get 'account', to: 'dashboard#account'
    end
  end

    # care homes under company for create and new because needed for creation. After creation, easy to get just
    # resources :care_homes, only: %i[index new create] do



  resources :care_homes, only: %i[show edit update destroy index] do
    resources :rooms, only: %i[index new create]
  end

  resources :rooms, only: %i[show edit update destroy] do
    resources :booking_enquiries, only: %i[new create]
  end

  resources :booking_enquiries, only: %i[show index edit update destroy]

  resources :local_authorities do
    resources :la_licences
  end

  get '/dashboard/:id/team', to: 'dashboard#team', as: 'dashboard_team'
  get '/dashboard/:id/new_team_member', to: 'dashboard#new_team_member', as: 'dashboard_new_team_member'
  post 'add_team_member', to: 'team_members#create'

  devise_for :users, path: '', path_names: { sign_in: 'login', sign_up: 'signup' }, controllers: { registrations: 'registrations' }
  get 'logout', to: 'pages#logout', as: 'logout'
  resources :after_signup, only: %i[show update]

  resources :subscribe, only: [:index]
  resources :dashboard, only: %i[index team new_team_member]
  resources :account, only: %i[index] do
    get :stop_impersonating, on: :collection
  end
  resources :billing_portal, only: [:new, :create]
  resources :blog_posts, controller: :blog_posts, path: "blog", param: :slug


  #get "subscriptions/index"
  #get "subscriptions/show"
  #get "subscriptions/new"
  #get "subscriptions/create"
  #get "subscriptions/edit"
  #get "subscriptions/update"
  #get "subscriptions/destroy"
  get "packages/index"
  get "packages/show"
  get "packages/new"
  post "packages", to: 'packages#create'
  get "packages/edit"
  get "packages/update"
  #get "packages/destroy"
  #get "activity_feeds/index"
  # static pages


  pages.each do |page|
    get "/#{page}", to: "pages##{page}", as: page.gsub('-', '_').to_s
  end

  # admin panels
  authenticated :user, lambda(&:admin?) do
    # insert sidekiq etc
    mount Split::Dashboard, at: 'admin/split'
  end

end
