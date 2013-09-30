ActiveAdmin.register Sms do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  menu :label => "Outgoing Messages", :parent => "Message"

  index do
    column :to
    column :text
    column "Sent at", :created_at
  end

  filter :to
  filter :text
  filter :created_at, :label => "Sent at"

  actions :index, :show
end
