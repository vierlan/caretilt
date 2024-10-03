# app/admin/users.rb
ActiveAdmin.register User do
  menu priority: 3

  # Specify parameters which should be permitted for assignment
  permit_params :email, :admin, :stripe_customer_id, :stripe_subscription_id, :phone_number

  # For security, limit the actions that should be available
  actions :all, except: [:new]

  member_action :impersonate, method: :get do
    user = User.find(params[:id])
    impersonate_user(user)
    redirect_to account_index_path
  end

  # Add or remove filters to toggle their visibility
  filter :email
  filter :created_at
  filter :updated_at
  filter :admin
  filter :paying_customer
  filter :phone_number

  # Add or remove columns to toggle their visibility in the index action
  index do
    selectable_column
    id_column
    column :email
    column :created_at
    column :updated_at
    column :paying_customer
    column 'Impersonate' do |user|
      link_to 'Login', impersonate_admin_user_path(user.id)
    end
    column :admin
    actions
  end

  # Add or remove rows to toggle their visibility in the show action
  show do
    attributes_table_for(resource) do
      row :id
      row :email
      row :encrypted_password
      row :reset_password_token
      row :reset_password_sent_at
      row :phone_number
    end
  end
end
