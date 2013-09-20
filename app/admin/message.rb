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
  actions :index
end