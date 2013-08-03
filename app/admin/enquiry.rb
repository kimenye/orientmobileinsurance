ActiveAdmin.register Enquiry do
  menu :parent => "Log"
  index do
    column :phone_number
    column :date_of_enquiry
    column :url
    column :source
    column "Hash", :hashed_phone_number
    column :sales_agent_code
    column :year_of_purchase
  end

  filter :phone_number
  actions :index
end