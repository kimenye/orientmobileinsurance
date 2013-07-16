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
end