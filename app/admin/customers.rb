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

  filter :name
  filter :id_passport
  filter :email
  filter :created_at

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  actions  :index, :show, :edit, :update
end
