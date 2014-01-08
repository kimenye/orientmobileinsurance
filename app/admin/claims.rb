ActiveAdmin.register Claim do

  controller do
    actions :all, :except => [:edit]
  end

  #index do
  #  column :claim_no
  #  column :claim_type
  #  column :incident_date
  #  column :policy
  #  column :status
  #end
  actions :index, :show, :destroy
end
