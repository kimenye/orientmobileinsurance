ActiveAdmin.register Sms, :as => "Outgoing Message" do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  menu :label => "Outgoing Messages", :parent => "Message"
end
