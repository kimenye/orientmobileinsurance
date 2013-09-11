ActiveAdmin.register Sms do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  menu :parent => "Log"
end
