class Claim < ActiveRecord::Base
  belongs_to :policy
  belongs_to :agent
  attr_accessible :claim_no, :claim_type, :contact_email, :contact_number, :incident_date, :incident_description, :policy_id, :status, :status_description,
                  :nearest_town, :step, :type_of_liquid, :visible_damage, :incident_location, :q_1, :q_2, :q_3, :q_4, :q_5, :agent_id,
                  :police_abstract, :receipt, :original_id, :copy_id, :blocking_request,
                  :dealer_description, :dealer_can_fix, :dealer_cost_estimate
end
