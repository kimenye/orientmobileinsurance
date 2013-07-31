class Claim < ActiveRecord::Base
  belongs_to :policy
  attr_accessible :claim_no, :claim_type, :contact_email, :contact_number, :incident_date, :incident_description, :policy_id, :status, :status_description, :nearest_town, :step, :type_of_liquid, :visible_damage, :incident_location
end
