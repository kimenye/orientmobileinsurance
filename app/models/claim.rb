class Claim < ActiveRecord::Base
  belongs_to :policy
  belongs_to :agent
  attr_accessible :claim_no, :claim_type, :contact_email, :contact_number, :incident_date, :incident_description, :policy_id, :status, :status_description,
                  :nearest_town, :step, :type_of_liquid, :visible_damage, :incident_location, :q_1, :q_2, :q_3, :q_4, :q_5, :agent_id,
                  :police_abstract, :receipt, :original_id, :copy_id, :blocking_request,
                  :dealer_description, :dealer_can_fix, :dealer_cost_estimate, :time_duration, :damaged_device,
                  :authorized, :replacement_limit, :decline_reason, :days_to_fix, :repair_limit, :authorization_type

  validates_acceptance_of :police_abstract, :allow_nil => false, if: :dealer_theft_claim?, accept: true
  validates_acceptance_of :copy_id, :allow_nil => false, if: :is_in_dealer_stage?, accept: true
  validates_acceptance_of :original_id, :allow_nil => false, if: :is_in_dealer_stage?, accept: true
  validates_acceptance_of :blocking_request, :allow_nil => false, if: :dealer_theft_claim?, accept: true
  validates_acceptance_of :receipt, :allow_nil => false, if: :is_in_dealer_stage?, accept: true
  validates_acceptance_of :damaged_device, :allow_nil => false, if: :dealer_damage_claim?, accept: true
  validates_presence_of :dealer_description, if: :dealer_damage_claim?


  def is_forward_to_koil?
    return step == 2
  end

  def claim_status
    if is_forward_to_koil?
      return "Claim # #{claim_no} has been forwarded to Kenya Orient for authorization"
    elsif is_in_customer_stage?
      return "Customer has not presented registration form at Dealer"
    else authorized
      return status_description
    end
  end

  def is_theft?
    claim_type == "Theft / Loss" || claim_type == "Loss/Theft"
  end

  def is_damage?
    claim_type == "Damage"
  end

  def is_in_customer_stage?
    return step.nil? || step == 1
  end

  def is_in_dealer_stage?
    return step == 2
  end

  private

  def dealer_theft_claim?
    is_in_dealer_stage? && is_theft?
  end

  def dealer_damage_claim?
    is_in_dealer_stage? && is_damage?
  end
end
