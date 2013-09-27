ActiveAdmin.register Customer, :as => "Lead"  do

  menu :label => "Leads"

  index do
    column :name
    column "Id / Passport" do |lead|
      link_to lead.id_passport, admin_lead_path(lead)
    end
    column :email
    column :num_enquiries
    column "Phone #1", :phone_number
    column "Phone #2", :alternate_number
  end

  show do |lead|
    panel "Lead Details" do
      attributes_table_for lead, :name, :id_passport, :email, :created_at
    end

    panel "Devices" do
      table_for(lead.insured_devices) do
        column "Model" do |id|
          link_to id.model, admin_insured_device_path(id)
        end
        column "Year of Purchase", :yop
        column "Phone Number", :phone_number
        column :created_at
        column :insured_value
        column "Premium", :premium
      end
    end

    active_admin_comments

  end

  csv do
    column :name
    column :id_passport
    column :email
    column :num_enquiries
    column :phone_number
    column :alternate_number
  end

  filter :name
  filter :id_passport
  filter :email
  filter :created_at

  controller do

    def scoped_collection
      Customer.where(:lead => true)
    end

    actions :all, :except => [:edit, :destroy]
  end

  actions  :index, :show, :edit, :update
end
