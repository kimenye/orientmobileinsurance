ActiveAdmin.register Quote do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  index do
    column :account_name
    column :amount_due
    column :expiry_date
    column :premium_type
    column :insured_value
    column :customer
    column :insured_device
  end

  filter :insured_device
  filter :agent
  filter :annual_premium
  filter :monthly_premium
  filter :account_name
  filter :premium_type
  filter :insured_device_customer_name, :as => :string, :label => "Customer Name"
  filter :insured_device_customer_id_passport, :as => :string, :label => "ID/Passport No"
  filter :insured_device_phone_number, :as => :string, :label => "Phone No"
  filter :expiry_date
  filter :created_at
  filter :updated_at
  filter :insured_value

  actions :index
end
