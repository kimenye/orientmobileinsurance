class ClaimService

  def find_nearest_towns
    towns = Brand.order("town_name").collect { |t| t.town_name }
  end

  def resolve_claim claim
    sms = SMSGateway.new
    to = claim.policy.customer.contact_number
    replacement = ActionController::Base.helpers.number_to_currency(claim.replacement_limit, :unit => "KES ", :precision => 0, :delimiter => "")
    if claim.is_damage? && claim.authorized
      # send an sms to the customer
      if claim.dealer_can_fix
        text = "Your #{claim.policy.insured_device.device.model} is under repair. Please collect it from #{claim.agent.name} on #{claim.days_to_fix.days.from_now.to_s(:simple)}. Please carry your ID / Passport"
        sms.send to, text
        claim.status_description = text
        claim.save!
        CustomerMailer.reparable_damage_claim(claim).deliver
      else
        text =  "Your #{claim.policy.insured_device.device.model}  cannot be repaired. Please visit #{claim.agent.name} with ID or Passport for a replacement. Limit #{replacement}"
        sms.send to, text
        claim.status_description = text
        claim.save!
        CustomerMailer.irreparable_damage_claim(claim).deliver
      end
    else
      if claim.is_theft? && claim.authorized
        text = "Your claim has been processed. Please visit #{claim.agent.name} with ID or Passport for a replacement device. Limit #{replacement}"
        sms.send to, text
        claim.status_description = text
        claim.save!
        CustomerMailer.loss_theft_claim(claim).deliver
      elsif claim.is_damage? && !claim.authorized
        CustomerMailer.claim_decline(claim).deliver
        text = "We regret to inform you that your Orient Mobile DAMAGE claim has been declined. Please check your email for details."
        sms.send to, text
        claim.status_description = text
        claim.save!
      elsif claim.is_theft? && !claim.authorized
        CustomerMailer.claim_decline(claim).deliver
        text = "We regret to inform you that your Orient Mobile THEFT claim has been declined. Please check your email for details."
        sms.send to, text
        claim.status_description = text
        claim.save!
      end
    end  
  end

  def notify_customer claim
    gateway = SMSGateway.new
    device = claim.policy.insured_device.device.marketing_name
    yop = claim.policy.insured_device.yop
    claim_type = "DAMAGE" if claim.is_damage?
    claim_type = "THEFT" if claim.is_theft?
    brand = find_brands_in_town claim.nearest_town
    customer = claim.policy.customer

    requirements = "the Claim Registration Form, damaged device, purchase receipt/ warranty and original &amp; copy of ID/ Passport." if claim.is_damage?
    requirements = "claim form, police abstract, stamped Blocking Request Form from network, purchase receipt/ warranty &amp; original &amp; copy of ID/Passport." if claim.is_theft?

    insured_value_str = ActionController::Base.helpers.number_to_currency(claim.policy.quote.insured_value, :unit => "KES ", :precision => 0, :delimiter => "")
    text = "#{device}, Year #{claim.policy.insured_device.yop}, Value #{insured_value_str}. #{claim_type} claim booked under Ref #{claim.claim_no}. Check email for Claim Registration Form. Please visit #{brand.brand_1} with #{requirements}"
    gateway.send(customer.contact_number, text)
  end
  
  def is_serial_claimant id_number
    customer = Customer.find_by_id_passport id_number

    if !customer.nil?
      #find all insured devices for this customer
      claims = find_claims_for_a_customer customer
      if !claims.empty?
        dates = claims.collect { |c| c.incident_date }

        dates = dates.reject { |d| d.nil? }
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