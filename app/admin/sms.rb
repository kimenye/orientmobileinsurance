ActiveAdmin.register Sms do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  menu :label => "Incoming SMS", :parent => "Log"
end
