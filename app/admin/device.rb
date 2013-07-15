ActiveAdmin.register Device do
  index do
    column :vendor
    column :model
    column :marketing_name
    column :catalog_price
    column :wholesale_price
  end

  form do |f|
    f.inputs "Device Details" do
      f.input :vendor
      f.input :model
      f.input :marketing_name
      f.input :catalog_price
      f.input :wholesale_price
    end
    f.actions
  end
end