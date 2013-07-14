ActiveAdmin.register Agent do
  index do
    column :town
    column :brand
    column :outlet
    column :location
    column :code
    column :email
    column :phone_number
  end

  filter :name

  form do |f|
    f.inputs "User Details" do
      f.input :code
      f.input :town
      f.input :brand
      f.input :outlet
      f.input :location
      f.input :phone_number
      f.input :email
    end
    f.actions
  end
end