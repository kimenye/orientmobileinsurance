ActiveAdmin.register InsuredDevice do

  menu :label => "Insurable Devices"
  index :title => "Insurable Devices"
  show :title => "Insurable Devices"

  filter :customer_id
  filter :device_id
  filter :imei
  filter :created_at
  filter :updated_at
  filter :yop
  filter :phone_number
  filter :customer_name, :as => :string, :label => "Customer Name"
  filter :device_marketing_name, :as => :string, :label => "Device Name"

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  actions :index, :show
end
