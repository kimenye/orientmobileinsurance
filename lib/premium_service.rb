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

  def calculate_monthly_premium agent_code, insurance_value
    base_premium = calculate_annual_premium agent_code, insurance_value, false, false
    raw = 1.15 * base_premium
    raw += 15
    mpesa_fee = calculate_mpesa_fee raw
    raw += mpesa_fee
    (raw / 3).round
  end

  def calculate_annual_premium agent_code, insurance_value, add_mpesa = true, add_sms_charges = true
    raw = calculate_premium_rate(agent_code) * insurance_value * 1.0045
    mpesa_fee = calculate_mpesa_fee raw
    raw += mpesa_fee if add_mpesa
    raw += 15 if add_sms_charges #sms charges
    [raw.round, minimum_fee(agent_code)].max
  end

  def minimum_fee agent_code
    fee = 999
    fee = 899 if is_fx_code agent_code
    fee
  end

  def is_fx_code code
    !code.nil? && code.start_with?("FX")
  end

  def generate_unique_account_number
    cs = [*'0'..'9', *'a'..'z', *'A'..'Z']
    6.times.map { cs.sample }.join.upcase
  end

  def calculate_premium_rate agent_code
    rate = 0.1
    rate = 0.095 if is_fx_code agent_code
    rate
  end
end