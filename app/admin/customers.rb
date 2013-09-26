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

    def scoped_collection
      Customer.where(:lead => true)
    end

    actions :all, :except => [:edit, :destroy]
  end

  actions  :index, :show, :edit, :update
end
