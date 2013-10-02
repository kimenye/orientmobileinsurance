ActiveAdmin.register Payment do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  index do
    column :amount
    column :method
    column :created_at
    column :reference
    column :for
    column :policy
    column :device
    column :customer
  end

  filter :amount
  filter :method
  filter :created_at
  filter :reference
  filter :status
  filter :policy
  filter :policy_quote_insured_device_customer_name, :as => :string, :label => "Customer Name"
  filter :policy_policy_number, :as => :string, :label => "Policy No"

  csv do
    column ("Customer") { |payment| payment.policy.quote.insured_device.customer.name }
    column ("Phone Number") { |payment| payment.policy.quote.insured_device.phone_number.nil? ? payment.policy.quote.insured_device.customer.phone_number : payment.policy.quote.insured_device.phone_number }
    column ("Device") { |payment| payment.policy.quote.insured_device.device.marketing_name }
    column ("Insured Value") { |payment| payment.policy.quote.insured_value }
    column ("Amount Paid") { |payment| payment.policy.amount_paid }
    column ("Premium Type") { |payment| payment.policy.payment_option }
    column ("Payment Due") { |payment| payment.policy.pending_amount }
    column ("Created At")  { |payment| payment.created_at.strftime("%d-%m-%Y") }
    column ("Account No.") { |payment| payment.policy.policy_number }
    column :reference
    column ("Payment Mode") { |payment| payment.method }
    column ("IMEI No") { |payment| payment.policy.quote.insured_device.imei }

  end

  actions :index
end
