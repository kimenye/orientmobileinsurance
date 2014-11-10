class PremiumService

  def is_insurable year_of_purchase
    current_year = Time.now.year
    if current_year - year_of_purchase <= 1
      return true
    else
      return false
    end
  end

  def is_insurable_by_month_and_year month_of_purchase, year_of_purchase
    time_of_purchase = "#{month_of_purchase} #{year_of_purchase}"
    if Device.month_ranges.include?(time_of_purchase)
      return true
    else
      return false
    end
  end

  def calculate_insurance_value catalog_price, sales_code, year_of_purchase
    if is_fx_code(sales_code) || is_stl_code(sales_code)
      return catalog_price
    elsif !is_fx_code(sales_code) && !is_stl_code(sales_code) && year_of_purchase == Time.now.year
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
    mpesa_fee_per_installment = calculate_mpesa_fee (installment / 3)
    mpesa_fee_per_installment *= 3
    installment += mpesa_fee_per_installment # add mpesa charges for installment

    installment.floor
  end

  def calculate_monthly_premium agent_code, insurance_value, yop, month=3
    base_premium = calculate_annual_premium agent_code, insurance_value, yop, false, false, true
    raw = calculate_total_installment base_premium
    round_off((raw / month).ceil)
  end

  def calculate_raw_annual_premium agent_code, insurance_value, yop
    calculate_annual_premium agent_code, insurance_value, yop, false, false, false, false
  end

  def calculate_raw_monthly_premium agent_code, insurance_value, yop
    annual = calculate_raw_annual_premium agent_code, insurance_value, yop
    (annual * 1.15 / 3).round
  end

  def calculate_levy premium
    (premium * 0.0045).round
  end

  def calculate_annual_premium agent_code, insurance_value, yop, add_mpesa = true, add_sms_charges = true, round_off = true, add_levy = true
    raw = calculate_premium_rate(agent_code, yop) * insurance_value
    raw = raw * 1.0045 if add_levy
    raw = [raw.round, minimum_fee(agent_code, yop)].max
    raw += 15 if add_sms_charges #sms charges
    mpesa_fee = calculate_mpesa_fee raw
    raw += mpesa_fee if add_mpesa

    agent = Agent.find_by_code(agent_code)
    if !agent.nil? && !agent.discount.nil?
      percentage_after_discount = (100 - agent.discount) / 100
      if agent.discount > 0
        raw = [(percentage_after_discount * raw), minimum_fee(agent_code, yop)].max
      end
    end

    # [raw.round, minimum_fee(agent_code)].max
    if round_off
      return round_off(raw.round)
    else
      return raw
    end
  end

  def round_off (number, nearest = 5)
    down = round_off_figure(number, nearest, "down")
    up = round_off_figure(number, nearest, "up")

    if (up - number) <= 2
      return up
    else
      return down
    end
  end


  def minimum_fee agent_code, yop
    fee = 595
    fee = 899 if (is_fx_code(agent_code) && yop == Time.now.year)
    fee
  end

  def is_stl_code code
    !code.nil? && code.start_with?("STL")
  end

  def is_fx_code code
    !code.nil? && (code.start_with?("FXP") || code.start_with?("TSK") || code.start_with?("PLK") || code.start_with?("NVS") )
  end

  def generate_unique_account_number
    cs = [*'0'..'9', *'a'..'z', *'A'..'Z']-['O']-['I']-['1']-['0']-['i']-['o']
    6.times.map { cs.sample }.join.upcase
  end

  def generate_unique_policy_number
    seed = ENV['SEED_POLICY_NO'].to_i + (Policy.count)

    "OMB/AAAA/%04d"% seed.to_s
  end

  def is_number? text
    true if Float(text) rescue false
  end

  def is_imei? text
    (!text.nil?) && text.strip.length == 15 && is_number?(text)
  end
  
  def get_message_type message
    if !message.nil?
      ENV['KEYWORDS'].split(",").each do |keyword|
        if message.downcase == keyword.strip.downcase
          return 1  
        end
      end
      if is_imei?(message)
        return 2
      else
        return 3
      end
    end
  end

  def calculate_premium_rate agent_code, yop
    rate = 0.1
    rate = 0.095 if (is_fx_code(agent_code) && yop == Time.now.year)
    rate
  end

  def is_valid_imei? imei
    id = InsuredDevice.find_by_imei imei
    if id.nil?
      return true
    else
      if id.quote.policy.is_active?
        return false
      else
	return true
      end
    end
  end

  def activate_policy imei, phone_number    
    if is_valid_imei? imei      
      inactive_devices = InsuredDevice.find_all_by_phone_number(phone_number).select { |id| id.imei.nil? && (!id.quote.nil? && !id.quote.policy.nil?) }

      if !inactive_devices.empty?
        device = inactive_devices.last
        device.imei = imei.strip
        device.save!

        policy = device.quote.policy
        set_policy_dates policy
        policy.save!

        if policy.status == "Active"
          sms_gateway = SMSGateway.new
          insured_value_str = ActionController::Base.helpers.number_to_currency(policy.quote.insured_value, :unit => "KES ", :precision => 0, :delimiter => "")
          sms_gateway.send phone_number, "You have successfully covered your device, value #{insured_value_str}. Orient Mobile policy #{policy.policy_number} valid till #{policy.expiry.to_s(:simple)}. Policy details: #{ENV['OMB_URL']}"
          email = CustomerMailer.policy_purchase(policy).deliver
        end
      else
        puts ">>> No devices found for the phone number #{phone_number}"
      end
    else
      sms_gateway = SMSGateway.new
      sms_gateway.send phone_number, "That IMEI number has already been activated for another policy. Please confirm and send again or call 0202962000."
    end
  end

  def set_policy_dates policy
    # if policy.status == "Inactive" || policy.status == "Pending"
    pending = policy.pending_amount
    if policy.quote.premium_type == "Annual"

      if pending <= 0
        policy.start_date = Time.now
        policy.expiry = 365.days.from_now
        policy.status = "Active"
      # else
        # policy.status = "Pending"
      end
    else
      if pending <= 0
        if policy.start_date.nil?
          policy.start_date = Time.now
          policy.expiry = 365.days.from_now
        else
          policy.expiry = policy.start_date + 365.days
        end
        policy.status = "Active"
      else
        if policy.start_date.nil?
          policy.start_date = Time.now
        end
        policy.expiry = 30.days.from_now
        policy.status = "Active"
      end
    end
    # end
  end

  private

  def round_off_figure(number, nearest=5, direction="down")
    if direction == "down"
      return number % nearest == 0 ? number : number - (number % nearest)
    else
      return number % nearest == 0 ? number : number + nearest - (number % nearest)
    end
  end
end
