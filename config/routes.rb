Rails.application.routes.draw do
  ActiveAdmin.routes(self)

  root 'pages#home'
  get 'verify/:id', to: 'users#verify', as: 'verify'
  patch '/verify_user/:id', to: 'users#verify_user'
  get '/dashboard/:id', to: 'dashboard#index', as: 'dashboard_index'
  get '/team_members/error', to: 'team_members#error', as: 'team_members_error'
  get '/team_members/:id/verify', to: 'team_members#verify_member', as: 'verify_member'
  patch '/team_members/:id/verify', to: 'team_members#verify_member_update'
  patch '/team_members/:id/make_inactive', to: 'team_members#make_user_inactive', as: 'make_inactive'
  get '/team_members/:id/make_inactive', to: 'team_members#make_user_inactive'


  resources :companies do
    member do
      get 'add_team_member', to: 'team_members#new' # Updated to use 'new' action
      get 'team', to: 'team_members#index'
      post 'add_team_member', to: 'team_members#create'
      get 'account', to: 'dashboard#account'
    end

    # care homes under company for create and new because needed for creation. After creation, easy to get just
    # resources :care_homes, only: %i[index new create] do
    resources :care_homes, only: %i[new create] do
      collection do
        get 'all'
      end
    end
  end

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

  # static pages
  pages = %w[
    privacy terms about contact home home2 home3 home4 guides calculator faq pricing search quiz test test2
  ]

  pages.each do |page|
    get "/#{page}", to: "pages##{page}", as: page.gsub('-', '_').to_s
  end

  # admin panels
  authenticated :user, lambda(&:admin?) do
    # insert sidekiq etc
    mount Split::Dashboard, at: 'admin/split'
  end

end
