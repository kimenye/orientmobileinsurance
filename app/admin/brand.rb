ActiveAdmin.register Brand do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  menu :parent => "Reference Data"
  active_admin_importable
  filter :town_name

  index do
    column :town_name
    column :brand_1
    column :brand_2
    column :brand_3
    column :brand_4
  end
  actions :index
end