ActiveAdmin.register Sms, :as => "Outgoing Message" do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  menu :label => "Outgoing Messages", :parent => "Message"

  index do
    column "To" do |sms|
      link_to sms.to, admin_outgoing_message_path(sms)
    end
    column :text
    column "Sent at", :created_at
  end

  filter :to
  filter :text
  filter :created_at, :label => "Sent at"

  actions :index, :show
end
