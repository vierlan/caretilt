Rails.application.routes.draw do
  get "la_licences/index"
  get "la_licences/show"
  get "la_licences/new"
  get "la_licences/create"
  get "la_licences/edit"
  get "la_licences/update"
  get "la_licences/destroy"
  get "rooms/index"
  get "rooms/show"
  get "rooms/new"
  get "rooms/create"
  get "rooms/edit"
  get "rooms/update"
  get "rooms/destroy"
  get "care_homes/index"
  get "care_homes/show"
  get "care_homes/new"
  get "care_homes/create"
  get "care_homes/edit"
  get "care_homes/update"
  get "care_homes/destroy"
  get "local_authorities/index"
  get "local_authorities/show"
  get "local_authorities/new"
  get "local_authorities/create"
  get "local_authorities/edit"
  get "local_authorities/update"
  get "local_authorities/destroy"
  get "companies/index"
  get "companies/show"
  get "companies/new"
  get "companies/create"
  get "companies/edit"
  get "companies/update"
  get "companies/destroy"
  ActiveAdmin.routes(self)

  root 'pages#home'

  resources :companies do
    resources :care_homes do
      resources :rooms
    end
  end

  resources :local_authorities do
    resources :la_licences
  end

  devise_for :users, path: '', path_names: { sign_in: 'login', sign_up: 'signup' }, controllers: { registrations: 'registrations' }
  get 'logout', to: 'pages#logout', as: 'logout'

  resources :subscribe, only: [:index]
  resources :dashboard, only: [:index]
  resources :account, only: %i[index update] do
    get :stop_impersonating, on: :collection
  end
  resources :billing_portal, only: [:new, :create]
  resources :blog_posts, controller: :blog_posts, path: "blog", param: :slug

  # static pages
  pages = %w[
    privacy terms about contact
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
