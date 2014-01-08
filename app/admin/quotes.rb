ActiveAdmin.register Quote do

  controller do
    actions :all, :except => [:destroy]
  end

  index do
    column "Contact Number" do |quote|
      quote.customer.phone_number
    end
    column "Account Name" do |quote|
      link_to quote.account_name, admin_quote_path(quote)
    end
    column :amount_due
    column :expiry_date
    column :premium_type
    column :insured_value
    # column :customer
    # column :insured_device
    default_actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :expiry_date, :as => :datepicker
    end
    f.actions
  end

  filter :insured_device
  filter :agent
  filter :annual_premium
  filter :monthly_premium
  filter :account_name
  filter :premium_type 
  filter :quote_type
  filter :customer_name, :as => :string, :label => "Customer Name"
  filter :customer_id_passport, :as => :string, :label => "ID/Passport No"
  filter :customer_phone_number, :as => :string, :label => "Phone No"
  filter :expiry_date
  filter :created_at
  filter :updated_at
  filter :insured_value

  actions :index, :edit, :update, :show
end
