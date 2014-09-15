ActiveAdmin.register Quote do
  scope :all
  scope :corporate
  scope :individual
  
  controller do
    actions :all, :except => [:destroy]
  end

  index do
    column "Contact Number" do |quote|
      quote.customer.phone_number
    end
    column "Account Name" do |quote|
      if quote.quote_type == "Corporate"
        link_to quote.account_name, quote_path(quote)
      else
        link_to quote.account_name, admin_quote_path(quote)
      end
    end
    column :amount_due
    column :expiry_date
    column :premium_type
    column :insured_value
    column :quote_type
    # column :customer
    # column :insured_device
    # default_actions
    actions defaults: true
  end

  # xlsx(:header_style => {:bg_color => 'C0BFBF', :fg_color => '000000' }) do
    
  #   delete_columns :id, :account_name, :annual_premium, :expiry_date, :monthly_premium, :insured_device_id, :premium_type, :insured_value, :agent_id, :quote_type, :customer_id, :created_at, :updated_at
    
  #   column("Customer ID") { |quote| quote.customer.id }
  #   column("Name") { |quote| quote.customer.name }
  #   column("Phone Number") { |quote| quote.customer.phone_number }
  #   column("Email") { |quote| quote.customer.email }
  #   column :annual_premium
  #   column :monthly_premium
  #   column :account_name
  #   column :premium_type
  #   column :expiry_date
  #   column :created_at
  #   column :updated_at
  #   column :insured_value
  #   column :quote_type
  # end

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
