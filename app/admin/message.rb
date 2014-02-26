ActiveAdmin.register Message, :as => "Incoming Message" do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  menu :parent => "Message", :label => "Incoming Messages"

  index do
    column :phone_number
    column :text
    column "Message Type", :kind
    column :created_at
  end

  filter :phone_number
  filter :text
  filter :created_at

  types = [ { id: 1, label: "Enquiry" }, { id: 2, label:  "IMEI" }, { id: 3, label: "Unknown" }]  
  filter :message_type, :collection => proc { types.map { |t| [ t[:label], t[:id] ] } }, :as => :select
  
  actions :index
end