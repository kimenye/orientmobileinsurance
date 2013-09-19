ActiveAdmin.register Enquiry do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  menu :parent => "Log"
  index do
    column :phone_number
    column :date_of_enquiry
    column :url
    column :source
    column "Hash(phone_number)", :hashed_phone_number
    column "Hash(timestamp)", :hashed_timestamp
    column :sales_agent_code
    column :year_of_purchase
    column "Vendor (DA)", :vendor
    column "Model (DA)", :model
    column "Name (DA)", :marketing_name
    column "Detected", :detected
  end

  filter :phone_number
  filter :year_of_purchase

  actions :index
end