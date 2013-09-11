ActiveAdmin.register Message do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  menu :parent => "Log"
  index do
    column :phone_number
    column :status
    column :text
    column "Message Type", :kind
    column :created_at
  end

  filter :phone_number
  actions :index
end