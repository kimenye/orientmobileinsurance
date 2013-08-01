ActiveAdmin.register Policy do
  index do
    column :policy_number
    column :customer
    column :start_date
    column :expiry
    column :status
    column "Premium", :premium
    column "Amount Paid", :amount_paid
    column :pending_amount
  end
  actions :index, :show
end
