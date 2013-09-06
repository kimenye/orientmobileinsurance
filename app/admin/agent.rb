ActiveAdmin.register Agent do
  menu :parent => "Reference Data"

  active_admin_importable do |model,hash|
    res = model.create! hash
    service = PremiumService.new()

    if service.is_fx_code res.code
      user = User.create! :name => "#{res.brand} #{res.outlet_name}", :email => "#{res.code}@korient.co.ke", :user_type => "DP", :agent_id => res.id,
        :password => "kenyaorient", :password_confirmation => "kenyaorient", :username => res.code
    end
  end

  # index do
#     column :town
#     column :brand
#     column :outlet
#     column :outlet_name
#     column :location
#     column :code
#     column :email
#     column :phone_number
#   end
  
  # actions :index, :delete

  filter :town
  filter :code

  form do |f|
    f.inputs "User Details" do
      f.input :code
      f.input :town
      f.input :brand
      f.input :outlet
      f.input :outlet_name
      f.input :location
      f.input :phone_number
      f.input :email
    end
    f.actions
  end
end