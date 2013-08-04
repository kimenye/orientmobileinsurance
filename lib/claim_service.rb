class ClaimService

  def approve_claim claim
    # CustomerMailer.policy_purchase(policy).deliver
  end
  
  def decline_claim claim
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