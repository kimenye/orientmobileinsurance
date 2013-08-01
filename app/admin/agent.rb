ActiveAdmin.register Agent do
  active_admin_importable
  index do
    column :town
    column :brand
    column :outlet
    column :outlet_name
    column :location
    column :code
    column :email
    column :phone_number
  end

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