require 'business_time'
class ClaimService

  def find_nearest_towns
    towns = Brand.order("town_name").collect { |t| t.town_name }
  end

  def find_nearest_brands town, is_stl, is_both=false
    b = Brand.find_by_town_name(town)
    brands = []
    if !b.nil?
      brands = [b.brand_1, b.brand_2, b.brand_3, b.brand_4, b.brand_5]
      brands.reject! { |b| b.nil? }
      if is_stl
        brands.reject! { |b| b != "Simba Telecom" }
      else
        brands.reject! { |b| b == "Simba Telecom" }
      end
    end
    brands
  end

  def find_nearest_locations claim
    towns = Brand.order("town_name")
    if claim.is_stl_only
      locations = towns.reject! { |t| !t.is_stl_location }
      return locations.collect { |t| t.town_name }
    # elsif claim.is_fxp_only
      # locations = towns.reject! { |t| t.is_stl_location }
      # return locations.collect { |t| t.town_name }
    else
      return towns.collect { |t| t.town_name }
    end
  end

  def resolve_claim claim
    sms = SMSGateway.new
    to = claim.policy.customer.contact_number
    replacement = ActionController::Base.helpers.number_to_currency(claim.replacement_limit, :unit => "KES ", :precision => 0, :delimiter => "")
    if claim.is_damage? && claim.authorized
      # send an sms to the customer
      if claim.dealer_can_fix && claim.authorization_type == "Repair"
        text = "Your #{claim.policy.insured_device.device.model} is under repair. Collect it from #{claim.agent.name} on #{(claim.days_to_fix + 1).business_days.from_now.to_s(:simple)}. Carry your ID / Passport"
        sms.send to, text
        claim.status_description = text
        claim.save!
        CustomerMailer.reparable_damage_claim(claim).deliver
      else
        text =  "Your #{claim.policy.insured_device.device.model} cannot be repaired. Visit #{claim.agent.name} with ID or Passport for a replacement. Limit #{replacement}"
        sms.send to, text
        claim.status_description = text
        claim.save!
        CustomerMailer.irreparable_damage_claim(claim).deliver
      end
    else
      if claim.is_theft? && claim.authorized
        text = "Your claim has been processed. Visit #{claim.agent.name} with ID or Passport for a replacement device. Limit #{replacement}"
        sms.send to, text
        claim.status_description = text
        claim.authorization_type = "Replace"
        claim.save!
        CustomerMailer.loss_theft_claim(claim).deliver
      elsif claim.is_damage? && !claim.authorized
        CustomerMailer.claim_decline(claim).deliver
        claim.authorization_type = "Decline"
        text = "We regret to inform you that your Orient Mobile DAMAGE claim has been declined. Check your email for details."
        sms.send to, text
        claim.status_description = text
        claim.save!
      elsif claim.is_theft? && !claim.authorized
        CustomerMailer.claim_decline(claim).deliver
        text = "We regret to inform you that your Orient Mobile THEFT claim has been declined. Check your email for details."
        sms.send to, text
        claim.authorization_type = "Decline"
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
    brand = find_nearest_brands(claim.nearest_town, claim.is_stl_only).first
    customer = claim.policy.customer

    requirements = "the Claim Registration Form, damaged device, purchase receipt/ warranty, original and copy of ID/ Passport." if claim.is_damage?
    requirements = "claim form, police abstract, stamped Blocking Request Form from network, purchase receipt/ warranty, original and copy of ID/Passport." if claim.is_theft?

    insured_value_str = ActionController::Base.helpers.number_to_currency(claim.policy.quote.insured_value, :unit => "KES ", :precision => 0, :delimiter => "")
    text = "#{device}, Year #{claim.policy.insured_device.yop}, Value #{insured_value_str}. #{claim_type} claim booked under Ref #{claim.claim_no}. Check email for Claim Registration Form."
    gateway.send(customer.contact_number, text)
    gateway.send(customer.contact_number, "Visit #{brand} with #{requirements}")
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
    dates = dates.last(3).sort!
    first_date = dates.first
    last_date = dates.last

    (last_date - first_date)/1.day <= 365
  end
  
  def get_replacement_amount_for_claim claim
    insured_value = 0.9 * claim.policy.quote.insured_value
    return insured_value
  end

  def create_claim_no
    
    last_claim = Claim.last
    if !last_claim.nil?
      next_digits = last_claim.claim_no[/\d{1,4}$/].to_i + 1
      next_digits_as_string = next_digits.to_s.rjust(4, '0')
      return "C/OMB/AAAA/"+next_digits_as_string
    else
      return "C/OMB/AAAA/0001"
    end
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