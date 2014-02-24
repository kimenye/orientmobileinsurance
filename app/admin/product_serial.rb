ActiveAdmin.register ProductSerial do
  menu :parent => "Reference Data"
  # active_admin_importable
  filter :product
  filter :serial
  filter :used

  index do
    column :product
    column :serial
    column :used 
    default_actions
  end
  
end