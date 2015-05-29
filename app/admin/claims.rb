ActiveAdmin.register Claim do
  scope :all
  scope :settled

  controller do
    actions :all, :except => [:edit]
  end

  

  index do
    column :id
    column ("Insured") {|claim| claim.policy.customer.name}
    column :claim_no
    column :policy
    column :claim_type
    column ("Mobile Device") { |claim| claim.policy.insured_device.device.name }
    column ("Claim Amount") {|claim| if claim.claim_type == "Damage"; claim.repair_limit 
                                     else claim.replacement_limit end}
    column :settlement_date
    column :authorization_type
    column ("Claim Registration Date") { |claim| claim.created_at.strftime("%d %b %Y")}
    # default_actions
    actions defaults: true
  end
   actions :index, :show

  # xlsx(:header_style => {:bg_color => 'C0BFBF', :fg_color => '000000' }) do
    
  #   column ("Insured") {|claim| claim.policy.customer.name}
  #   column ("Policy")  {|claim| claim.policy.policy_number }

  # end

  csv do
    column :id
    column ("Insured") {|claim| claim.policy.customer.name}
    column :claim_no
    column ("Policy") {|claim| claim.policy.policy_number }
    column :claim_type
    column ("Mobile Device") {|claim| claim.policy.insured_device.device.vendor + " " +
                                      claim.policy.insured_device.device.model }
    column ("Claim Amount") {|claim| if claim.claim_type == "Damage"; claim.repair_limit 
                                     else claim.replacement_limit end}
    column :settlement_date
    column :authorization_type
    column ("Claim Registration Date") { |claim| claim.created_at.strftime("%d %b %Y")}
  end

  filter :policy_insured_device_customer_name, :as => :string, :label => "Customer Name"
  filter :claim_no
  filter :policy_policy_number, :as => :string, :label => "Policy"
  filter :settlement_date
  filter :authorization_type, :as => :select, :collection => ["Decline", "Repair", "Replace"]
end
