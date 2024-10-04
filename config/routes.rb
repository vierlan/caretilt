Rails.application.routes.draw do
  root 'pages#home'
  ActiveAdmin.routes(self)

  #debug session route
  #get '/session', to: 'activity_feeds#index'
  get 'verify/:id', to: 'users#verify', as: 'verify'
  patch 'verify/:id', to: 'users#verify_user'
  get '/team_members/:id/verify', to: 'team_members#verify_member', as: 'verify_member'
  patch '/team_members/:id/verify', to: 'team_members#verify_member_update'
  delete '/team_members/:id', to: 'team_members#destroy', as: 'delete_member'
  get '/checkout', to: 'stripe/checkout#show', as: 'checkout'
  #post '/checkout', to: 'stripe/checkout#checkout'
  get '/checkout/add_credits', to: 'stripe/checkout#add_credits'
  get '/checkout/pricing', to: 'stripe/checkout#pricing'
  get '/checkout/success', to: 'stripe/checkout#success'
  get '/checkout/cancel', to: 'stripe/checkout#cancel'
  get 'activity_feeds', to: 'activity_feeds#index'
  get '/checkout/get_stripe_events', to: 'stripe/checkout#get_stripe_events'

  resources :subscriptions, only: [:edit, :update] do
    collection do
      post :deactivate_expired
    end
  end
  resources :companies do
    get :stop_impersonating, on: :collection
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

  resources :local_authorities do
    member do
      get 'add_team_member', to: 'team_members#new', as: 'la_member'
      get 'team', to: 'team_members#index'

      post 'add_team_member', to: 'team_members#create'
      get 'account', to: 'dashboard#account'
    end
  end

    # care homes under company for create and new because needed for creation. After creation, easy to get just
    # resources :care_homes, only: %i[index new create] do
  resources :care_homes, only: %i[show edit update destroy index] do
    # This is for the drag reordering and delete button to remove the media for the correct care home and save to database.

    # member is used for a single instance of care_home i.e care_home:id
    member do
      patch :move_media
      delete :remove_media
    end

    resources :rooms, only: %i[index new create]
  end

  resources :rooms, only: %i[show edit update destroy] do
    resources :booking_enquiries, only: %i[new create]
  end

  resources :booking_enquiries, only: %i[show index edit update destroy]

  get '/dashboard/:id/team', to: 'dashboard#team', as: 'dashboard_team'
  get '/dashboard/:id/new_team_member', to: 'dashboard#new_team_member', as: 'dashboard_new_team_member'
  post 'add_team_member', to: 'team_members#create'

  get  'two_factor_authentication', to: 'users/two_factor_authentication#show', as: :two_factor_authentication
  post 'two_factor_authentication/send_verification', to: 'users/two_factor_authentication#send_verification', as: :send_otp
  post 'two_factor_authentication/verify_otp', to: 'users/two_factor_authentication#verify_otp', as: :verify_otp


  devise_for :users, path: '', path_names: { sign_in: 'login', sign_up: 'signup' }, controllers: { registrations: 'registrations' }
  get 'logout', to: 'pages#logout', as: 'logout'
  resources :after_signup, only: %i[show update]

  resources :subscribe, only: [:index]
  resources :dashboard, only: %i[index team new_team_member]
  resources :account, only: %i[index] do
    get :stop_impersonating, on: :collection
  end
  resources :billing_portal_sessions, only: [:new, :create]
  resources :blog_posts, controller: :blog_posts, path: "blog", param: :slug

 resources :packages do
    resources :subscriptions, only: %i[new create]
  end

  # static pages

  # new/create and send email for contact form
  get "contact_mailer/contact_email"
  get "contact", to: "contact_mailer#new", as: :contact
  post "contact", to: "contact_mailer#create", as: :contact_email

  pages = %w[
    privacy terms about home home2 home3 home4 guides calculator faq pricing search quiz test test2
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
