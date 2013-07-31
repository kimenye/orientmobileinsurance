ActiveAdmin.register Message do
  index do
    column :phone_number
    column :status
    column :text
    column "Message Type", :kind
  end

  filter :phone_number
  actions :index
end