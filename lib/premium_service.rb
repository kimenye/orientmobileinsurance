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
end