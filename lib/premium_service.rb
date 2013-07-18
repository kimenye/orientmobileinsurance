class PremiumService

  def initialize

  end

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

    if sales_code.include?("FX")
      return catalog_price
    elsif (sales_code.nil? || !sales_code.include?("FX")) && year_of_purchase == Time.now.year
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

  def calculate_premium_rate agent_code
    rate = 0.1
    rate = 0.095 if !agent_code.nil? && agent_code.include?("FX")
    rate
  end
end