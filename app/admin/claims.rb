ActiveAdmin.register Claim do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  #index do
  #  column :claim_no
  #  column :claim_type
  #  column :incident_date
  #  column :policy
  #  column :status
  #end
  actions :index, :show
end
