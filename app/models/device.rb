class Device < ActiveRecord::Base

  validates :vendor, presence: true
  validates :model, presence: true
  validates :marketing_name, presence: true
  # validates :catalog_price, presence: true
  #validates :wholesale_price, presence: true
  #validates :catalog_price, numericality: { :greater_than_or_equal_to => :wholesale_price }
  #validates :wholesale_price, numericality: { :less_than_or_equal_to => :catalog_price }

  attr_accessible :vendor, :model, :marketing_name, :catalog_price, :wholesale_price, :fd_insured_value, :device_type,
                  :fd_replacement_value, :fd_koil_invoice_value, :yop_insured_value, :yop_replacement_value,
                  :yop_fd_koil_invoice_value, :prev_insured_value, :prev_replacement_value, :prev_fd_koil_invoice_value, 
                  :stock_code, :active, :version, :stl_insured_value, :stl_replacement_value, :stl_koil_invoice_value, :dealer_code


  scope :model_search, (lambda do |vendor, model|
    {:conditions => ["lower(vendor) like ? and active = 't' and lower(model) like ?", "#{!vendor.nil? ? vendor.downcase : '%'}", "#{!model.nil? ? model.downcase : '%'}"] }
  end )

  scope :model_like_search, (lambda do |vendor, model|
    {:conditions => ["lower(vendor) like ? and active = 't' and lower(model) like ?", "#{!vendor.nil? ? vendor.downcase+'%' : '%'}", "#{!model.nil? ? model.downcase+'%' : '%'}"] }
  end )

  scope :device_similar_to, (lambda do |vendor, model, marketing_name|
    {:conditions => [ "lower(vendor) like ? and active = 't' and (lower(model) like ? or lower(marketing_name) like ? )", "#{!vendor.nil? ? vendor.downcase : '%'}", "#{!model.nil? ? model.downcase : '%'}", "#{!marketing_name.nil? ? marketing_name.downcase : '%'}" ]}
  end )

  scope :wider_search, (lambda do |model|
    {:conditions => [ "lower(model) like ? and active = 't'", "%#{!model.nil? ? model.downcase : '%'}%"]}

  end )

  def get_insurance_value (code, year_of_purchase)
    get_insurance_value_by_year(code, year_of_purchase)
  end

  def get_insurance_value_by_year (code, year_of_purchase)
    service = PremiumService.new
    if (service.is_fx_code(code) || service.is_stl_code(code))  && Time.now.year == year_of_purchase
      return fd_insured_value
    elsif year_of_purchase == Time.now.year
      return yop_insured_value
    else
      return prev_insured_value
    end
  end

  def get_insurance_value_by_month_range (code, month_range)
    if month_range == 0
      return catalog_price
    elsif month_range == 1
      return 0.95 * catalog_price
    elsif month_range == 2
      return 0.875 * catalog_price
    elsif month_range == 3
      return 0.75 * catalog_price
    elsif month_range == 4
      return 0.5 * catalog_price
    elsif month_range == 5
      return 0.25 * catalog_price
    end
  end

  def self.month_ranges
    months = Date::MONTHNAMES

    current_month = Time.now.month
    month_yrs = months[1..current_month].collect{|m| "#{m} #{Time.now.year}"}.reverse + months[1..12].collect{|m| "#{m} #{Time.now.year - 1}"}.reverse + months[current_month..12].collect{|m| "#{m} #{Time.now.year - 2}"}.reverse
    # month_ranges = [[month_yrs[6],month_yrs[0]].join(" - "), [month_yrs[9],month_yrs[7]].join(" - "), [month_yrs[12],month_yrs[10]].join(" - "), [month_yrs[15],month_yrs[13]].join(" - "), [month_yrs[18],month_yrs[16]].join(" - "), [month_yrs[24],month_yrs[19]].join(" - ")]
    
    return month_yrs
  end

  def get_insurance_value_by_month_and_year (code, month_of_purchase, year_of_purchase)
    service = PremiumService.new
    time_of_purchase = "#{month_of_purchase} #{year_of_purchase}"
    month_ranges = Device.month_ranges
    if service.is_fx_code(code) && month_ranges[0..12].include?(time_of_purchase)
      return catalog_price
    else
      if month_ranges[0..6].include?(time_of_purchase)
        return catalog_price
      elsif month_ranges[7..9].include?(time_of_purchase)
        return 0.95 * catalog_price
      elsif month_ranges[10..12].include?(time_of_purchase)
        return 0.875 * catalog_price
      elsif month_ranges[13..15].include?(time_of_purchase)
        return 0.75 * catalog_price
      elsif month_ranges[16..18].include?(time_of_purchase)
        return 0.5 * catalog_price
      elsif month_ranges[19..24].include?(time_of_purchase)
        return 0.25 * catalog_price
      end
    end
  end

  def self.get_marketing_search_parameter (term)
    if !term.nil?
      escaped_term = term.gsub! /\s+/, '%'
      return "%#{escaped_term}%" if !escaped_term.nil?
    end
    return ""
  end

  def is_stl
    return (vendor == "Tecno" || vendor == "G-Tide" || vendor == "iTel" || vendor == "Forme")
  end

  def is_servicable_at_stl
    return is_stl || dealer_code == "STL"
  end

  def is_servicable_at_both
    dealer_code == "Both"
  end

  def to_s
    "#{vendor} #{model}"
  end

  def name
    to_s
  end
end
