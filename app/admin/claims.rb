ActiveAdmin.register Claim do

  controller do
    actions :all, :except => [:edit]
  end

  

  index do
    column :id
    column ("Isured") {|claim| claim.policy.customer.name}
    column :claim_no
    column :policy
    column :claim_type
    column ("Mobile Device") {|claim| claim.policy.quote.insured_device.device.vendor + " " +
                                      claim.policy.quote.insured_device.device.model }
    column ("Claim Amount") {|claim| if claim.claim_type == "Damage"; claim.repair_limit 
                                     else claim.replacement_limit end}
    column :settlement_date
    column :authorization_type
    column ("Claim Registration Date") { |claim| claim.created_at.strftime("%d %b %Y")}
    default_actions
  end
   actions :index, :show, :destroy

  csv do
    column :id
    column ("Isured") {|claim| claim.policy.customer.name}
    column :claim_no
    column :policy
    column :claim_type
    column ("Mobile Device") {|claim| claim.policy.quote.insured_device.device.vendor + " " +
                                      claim.policy.quote.insured_device.device.model }
    column ("Claim Amount") {|claim| if claim.claim_type == "Damage"; claim.repair_limit 
                                     else claim.replacement_limit end}
    column :settlement_date
    column :authorization_type
    column ("Claim Registration Date") { |claim| claim.created_at.strftime("%d %b %Y")}
  end


end
