ActiveAdmin.register Enquiry do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  menu :parent => "Log"
  index do
    column :phone_number
    column :created_at
    column :url
    column :source
    column :sales_agent_code
    column :year_of_purchase
    column "Vendor (DA)", :vendor
    column "Model (DA)", :model
    column "Name (DA)", :marketing_name
    column "Detected", :detected
  end

  filter :phone_number
  filter :year_of_purchase
  filter :vendor
  filter :model
  filter :marketing_name
  filter :created_at

  actions :index
end