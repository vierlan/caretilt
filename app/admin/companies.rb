ActiveAdmin.register User do
  menu priority: 7

  # Specify parameters which should be permitted for assignment
  permit_params :email, :companies_house_id, :stripe_customer_id, :stripe_subscription_id

  # For security, limit the actions that should be available
  actions :all, except: [:new]

  # Add or remove filters to toggle their visibility
  filter :email
  filter :created_at
  filter :updated_at
  filter :super_pin
  filter :phone_number

  # Add or remove columns to toggle their visiblity in the index action
  index do
    selectable_column
    id_column
    column :email
    column :created_at
    column :updated_at
    column :stripe_customer_id
    column 'Impersonate' do |user|
      link_to 'Login', impersonate_admin_user_path(user.id)
    end
    column :role
    actions
  end

  # Add or remove rows to toggle their visiblity in the show action
  show do
    attributes_table_for(resource) do
      row :id
      row :email
      row :stripe_customer_id
      row :stripe_subscription_id
      row :paying_customer
    end
  end

  # Add or remove fields to toggle their visibility in the form
  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :email
      f.input :admin
      f.input :stripe_customer_id
      f.input :stripe_subscription_id
    end
    f.actions
  end
end
