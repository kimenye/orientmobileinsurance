ActiveAdmin.register Payment do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  index do
    column "Contact Number" do |payment|
      payment.quote.customer.phone_number
    end
    column :amount
    column :method
    column :created_at
    column :reference
    column :account
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
  filter :policy_quote_customer_name, :as => :string, :label => "Customer Name"
  filter :policy_policy_number, :as => :string, :label => "Policy No"
  filter :policy_quote_insured_device_phone_number, :as => :string, :label => "Phone Number"
  filter :policy_quote_account_name, :as => :string, :label => "Account"

  csv do
    column ("Customer") { |payment| payment.quote.customer.name }
    column ("Phone Number") { |payment| payment.quote.customer.phone_number }
    column ("Email Address") { |payment| payment.quote.customer.email }
    column ("Device") { |payment| payment.policy.insured_device.device.marketing_name if !payment.policy.nil? }
    column ("Insured Value") { |payment| payment.policy.insured_device.insurance_value if !payment.policy.nil? }
    column ("Amount Paid") { |payment| payment.amount }
    column ("Premium Type") { |payment| payment.quote.payment_option }
    column ("Payment Due") { |payment| payment.policy.pending_amount if !payment.policy.nil? }
    column ("Created At")  { |payment| payment.created_at.strftime("%d-%m-%Y") }
    column ("Account No.") { |payment| payment.policy.policy_number if !payment.policy.nil? }
    column :reference
    column ("Payment Mode") { |payment| payment.method }
    column ("IMEI No") { |payment| payment.policy.insured_device.imei if !payment.policy.nil? }

  end

  actions :index
end
