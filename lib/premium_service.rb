class PremiumService

  def is_insurable year_of_purchase, sales_code
    current_year = Time.now.year
    if sales_code.nil? && current_year - year_of_purchase <= 1
      return true
    elsif !sales_code.nil?
      return true
    end
    return false
  end

  def calculate_insurance_value catalog_price, sales_code, year_of_purchase

    if is_fx_code sales_code
      return catalog_price
    elsif !is_fx_code(sales_code) && year_of_purchase == Time.now.year
      return 0.875 * catalog_price
    else
      return 0.375 * catalog_price
    end
  end

  def calculate_mpesa_fee transfer_value
    fee = 0
    if transfer_value >= 1000 && transfer_value <= 2499
      fee = 11
    elsif transfer_value >= 2500 && transfer_value <= 4999
      fee = 33
    elsif transfer_value >= 5000 && transfer_value <= 9999
      fee = 61
    elsif transfer_value >= 10000 && transfer_value <= 19999
      fee = 77
    elsif transfer_value >= 20000 && transfer_value <= 34999
      fee = 132
    elsif transfer_value >= 35000 && transfer_value <= 49999
      fee = 154
    elsif transfer_value >= 50000 && transfer_value <= 70000
      fee = 165
    end
    fee
  end

  def get_status_message quote    
    if quote.policy.nil?
      amount_due = ActionController::Base.helpers.number_to_currency(quote.amount_due, :unit => "KES ", :precision => 0, :delimiter => "")
      expected = "The Orient Mobile policy for this device has an outstanding balance of #{amount_due}. Your account no. is #{quote.account_name}. Please pay via MPesa (Business No. #{ENV['MPESA']}) or Airtel Money (Business Name #{ENV['AIRTEL']}).  You can register your claim after payment confirmation."
      return expected
    elsif quote.policy.is_owing?
      amount_due = ActionController::Base.helpers.number_to_currency(quote.policy.pending_amount, :unit => "KES ", :precision => 0, :delimiter => "")
      expected = "The Orient Mobile policy for this device has an outstanding balance of #{amount_due}. Your account no. is #{quote.account_name}. Please pay via MPesa (Business No. #{ENV['MPESA']}) or Airtel Money (Business Name #{ENV['AIRTEL']}).  You can register your claim after payment confirmation."
      return expected
    elsif quote.policy.is_pending?
      return "To activate your policy Dial *#06# to retrieve the 15-digit IMEI no. of your device. Record this & SMS starting with OMI and the number to #{ENV['SHORT_CODE']} to receive your Orient Mobile policy confirmation."
    end
  end

  def calculate_total_installment base_premium
    installment = 1.15 * base_premium  # 115% of annual premium
    installment += 15 # add sms charges
    installment += calculate_mpesa_fee (installment / 3) # add mpesa charges for installment

    installment.floor
  end

  def calculate_monthly_premium agent_code, insurance_value
    base_premium = calculate_annual_premium agent_code, insurance_value, false, false
    raw = calculate_total_installment base_premium
    (raw / 3).ceil
  end

  def calculate_annual_premium agent_code, insurance_value, add_mpesa = true, add_sms_charges = true
    raw = calculate_premium_rate(agent_code) * insurance_value * 1.0045
    raw = [raw.round, minimum_fee(agent_code)].max
    raw += 15 if add_sms_charges #sms charges
    mpesa_fee = calculate_mpesa_fee raw
    raw += mpesa_fee if add_mpesa

    # [raw.round, minimum_fee(agent_code)].max
    raw.round
  end

  def minimum_fee agent_code
    fee = 999
    fee = 899 if is_fx_code agent_code
    fee
  end

  def is_fx_code code
    !code.nil? && (code.start_with?("FXP") || code.start_with?("TSK") || code.start_with?("PLK") || code.start_with?("NVS") )
  end

  def generate_unique_account_number
    cs = [*'0'..'9', *'a'..'z', *'A'..'Z']-['O']-['I']-['1']-['0']-['i']-['o']
    6.times.map { cs.sample }.join.upcase
  end

  def generate_unique_policy_number
    "OMB/AAAA/%04d"% (Policy.count + 1).to_s
  end

  def is_number? text
    true if Float(text) rescue false
  end

  def is_imei? text
    (!text.nil?) && text.strip.length == 15 && is_number?(text)
  end

  def get_message_type message
    if !message.nil? && message.downcase == ENV['KEYWORD'].downcase
      return 1
    elsif is_imei?(message)
      return 2
    else
      return 3
    end
  end

  def calculate_premium_rate agent_code
    rate = 0.1
    rate = 0.095 if is_fx_code agent_code
    rate
  end

  def activate_policy imei, phone_number

    inactive_devices = InsuredDevice.find_all_by_phone_number(phone_number).select { |id| id.imei.nil? && (!id.quote.policy.nil?) }
    if !inactive_devices.empty?
      device = inactive_devices.last
      device.imei = imei.strip
      device.save!

      policy = device.quote.policy
      set_policy_dates policy
      policy.save!

      #You have successfully covered your device, value KES 19500. Orient Mobile policy OMB/AAAA/0001 valid till 11/07/14. Policy details: www.korient.co.ke/OMB/T&C
      if policy.status == "Active"
        sms_gateway = SMSGateway.new
        insured_value_str = ActionController::Base.helpers.number_to_currency(policy.quote.insured_value, :unit => "KES ", :precision => 0, :delimiter => "")
        sms_gateway.send phone_number, "You have successfully covered your device, value #{insured_value_str}. Orient Mobile policy #{policy.policy_number} valid till #{policy.expiry.to_s(:simple)}. Policy details: www.korient.co.ke/LoveMob"
        email = CustomerMailer.policy_purchase(policy).deliver
      end
    else
      puts ">>> No devices found for the phone number #{phone_number}"
    end
  end

  def set_policy_dates policy
    # if policy.status == "Inactive" || policy.status == "Pending"
    pending = policy.pending_amount
    if policy.quote.premium_type == "Annual"

      if pending == 0
        policy.start_date = Time.now
        policy.expiry = 365.days.from_now
        policy.status = "Active"
      # else
        # policy.status = "Pending"
      end
    else
      if pending == 0
        policy.start_date = Time.now
        policy.expiry = 365.days.from_now
        policy.status = "Active"
      else
        policy.start_date = Time.now
        policy.expiry = 30.days.from_now
        policy.status = "Active"
      end
    end
    # end
  end
end