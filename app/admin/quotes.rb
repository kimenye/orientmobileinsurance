ActiveAdmin.register Quote do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  index do
    column :account_name
    column :amount_due
    column :expiry_date
    column :premium_type
    column :insured_value
    column :customer
    column :insured_device
  end
  actions :index
end
