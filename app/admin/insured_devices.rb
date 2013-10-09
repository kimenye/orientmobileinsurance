ActiveAdmin.register InsuredDevice do

  menu :label => "Insurable Devices"
  #index :title => "Insurable Devices"
  show :title => "Insurable Devices"

  index :title => "Insurable Devices" do
    column :customer_id
    column :device_id
    column :imei
    column :created_at
    column :updated_at
    column :yop
    column :phone_number

    column "Customer Name" do |ins_dev|
      ins_dev.customer.name
    end

    column "Device Name" do |ins_dev|
      ins_dev.device.marketing_name
    end

    column "Customer Email" do |ins_dev|
      ins_dev.customer.email
    end

    default_actions
  end

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
