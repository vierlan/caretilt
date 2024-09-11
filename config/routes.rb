Rails.application.routes.draw do
  ActiveAdmin.routes(self)

  root 'pages#home'

  get '/dashboard/:id', to: 'dashboard#index', as: 'dashboard_index'

  resources :companies do
    resources :care_homes do
      resources :rooms
    end
  end

  resources :local_authorities do
    resources :la_licences
  end

  get '/dashboard/:id/team', to: 'dashboard#team', as: 'dashboard_team'

  devise_for :users, path: '', path_names: { sign_in: 'login', sign_up: 'signup' }, controllers: { registrations: 'registrations' }
  get 'logout', to: 'pages#logout', as: 'logout'
  resources :after_signup, only: %i[show update]

  resources :subscribe, only: [:index]
  resources :dashboard, only: %i[index team]
  resources :account, only: %i[index update] do
    get :stop_impersonating, on: :collection
  end
  resources :billing_portal, only: [:new, :create]
  resources :blog_posts, controller: :blog_posts, path: "blog", param: :slug

  # static pages
  pages = %w[
    privacy terms about contact home home2 home3 home4 guides calculator faq pricing test
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
