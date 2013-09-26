ActiveAdmin.register Customer, :as => "Lead"  do

  menu :label => "Leads"

  index do
    column :name
    column "Id / Passport" do |lead|
      link_to lead.id_passport, admin_lead_path(lead)
    end
    column :email
    column :num_enquiries
  end

  show do |lead|
    panel "Lead Details" do
      attributes_table_for lead, :name, :id_passport, :email, :created_at
    end

  end

  filter :name
  filter :id_passport
  filter :email
  filter :created_at

  controller do

    #def scoped_collection
      #Customer.joins("inner join insured_devices on insured_devices.customer_id = customers.id").joins("inner join quotes on quotes.insured_device_id = insured_devices.id").joins("inner join policies on policies.quote_id = quotes.id").where("quote.policy_id = ?", nil)
      #Customer.joins("inner join insured_devices on insured_devices.customer_id = customers.id").joins("inner join quotes on quotes.insured_device_id = insured_devices.id").joins("left outer join policies on policies.quote_id = quotes.id").where("policies.quote_id = ?",nil)
    #end

    #Customer.joins("inner join insured_devices on insured_devices.customer_id = customers.id").joins("inner join quotes on quotes.insured_device_id = insured_devices.id").joins("inner join policies on policies.quote_id = quotes.id")
    actions :all, :except => [:edit, :destroy]
  end

  actions  :index, :show, :edit, :update
end
