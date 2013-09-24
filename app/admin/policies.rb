ActiveAdmin.register Policy, :as => "Customer" do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  index do
    column :customer
    column :policy_number
    column :start_date
    column :expiry
    column :payment_option
    column "Total Due", :premium
    column "Amount Paid", :amount_paid
    column "Total Balance", :pending_amount
    column "Next Payment Due", :minimum_due
    column "IMEI", :imei
    column :sales_agent_code
    column :sales_agent_name
  end

  filter :policy_number
  filter :start_date
  filter :expiry

  actions :index, :show
end
