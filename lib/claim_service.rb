class ClaimService

  def resolve_claim claim
    sms = SMSGateway.new
    to = claim.policy.customer.contact_number
    replacement = ActionController::Base.helpers.number_to_currency(claim.replaclacement_limited, :unit => "KES ", :precision => 0)
    if claim.is_damage? && claim.approved
      # send an sms to the customer
      if claim.dealer_can_fix
        sms.send to, "Your #{claim.policy.insured_device.device.model} is under repair. Please collect it from #{claim.agent.name} on #{claim.time_duration.days.from_now.to_s(:simple)}. Please carry your ID / Passport"
        CustomerMailer.reparable_damage_claim(claim).deliver
      else
        sms.send to, "Your #{claim.policy.insured_device.device.model}  cannot be repaired. Please visit #{claim.agent.name} with ID or Passport for a replacement. Limit #{replacement}"
        CustomerMailer.irreparable_damage_claim(claim).deliver
      end
    else
      if claim.is_theft? && claim.approved
        sms.send to, "Your claim has been procesed. Please visit #{claim.agent.name} with ID or Passport for a replacement device. Limit #{replacement}"
        CustomerMailer.loss_theft_claim(claim).deliver
      elsif claim.is_damage? && !claim.approved
        CustomerMailer.claim_decline(claim).deliver
        sms.send to "We regret to inform you that your Orient Mobile DAMAGE claim has been declined. Please check your email for details."
      end
    end  
  end
  
  def is_serial_claimant id_number
    customer = Customer.find_by_id_passport id_number

    if !customer.nil?
      #find all insured devices for this customer
      claims = find_claims_for_a_customer customer
      if !claims.empty?
        dates = claims.collect { |c| c.incident_date }
        return dates_in_same_calendar_year dates
      end
    end
    return false
  end

  def dates_in_same_calendar_year dates
    dates.sort!
    first_date = dates.first
    last_date = dates.last

    (last_date - first_date)/1.day <= 365
  end

  def create_claim_no
    "C/OMB/AAAA/%04d"% (Claim.count + 1).to_s
  end

  def find_brands_in_town town
    Brand.all(:conditions => ['lower(town_name) = ?', town.downcase]).first
  end

  private

  def find_claims_for_a_customer customer
    insured_devices = customer.insured_devices
    if !insured_devices.empty?
      #find all claims quotes for those insured devices
      quotes = Quote.where('insured_device_id in (:ids)', :ids => insured_devices.collect { |d| d.id })
      if !quotes.empty?
        #find all the policies for these quotes
        policies = Policy.where('quote_id in (:ids)', :ids => quotes.collect { |q| q.id })
        if !policies.empty?
          #find all the claims for these quotes
          claims = policies.collect { |p| p.claims if !p.claims.empty? }.flatten
          claims.reject! { |c| c.nil? }
          return claims
        end
      end
    end
    return []
  end

end