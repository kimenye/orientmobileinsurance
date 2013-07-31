ActiveAdmin.register Quote do
  index do
    column :account_name
    column :amount_due
    column :expiry_date
    column :premium_type
    column :insured_value
    column :customer
  end
  actions :index
end
