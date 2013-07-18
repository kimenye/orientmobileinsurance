ActiveAdmin.register Enquiry do
  index do
    column :phone_number
    column :date_of_enquiry
    column :url
    column :source
    column "Hash", :hashed_phone_number
  end

  filter :phone_number
  actions :index
end