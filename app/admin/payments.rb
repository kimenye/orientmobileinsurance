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

  csv do
    column :amount
    column :method
    column :created_at
    column :reference
    column ("For") { |payment| payment.policy.policy_number }
    column ("Policy") { |payment| payment.policy.policy_number }
    column ("Device") { |payment| payment.policy.quote.insured_device.device.marketing_name }
    column ("Customer") { |payment| payment.policy.quote.insured_device.customer.name }
  end

  actions :index
end
