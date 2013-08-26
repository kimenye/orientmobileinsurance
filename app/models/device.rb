class Device < ActiveRecord::Base

  validates :vendor, presence: true
  validates :model, presence: true
  validates :marketing_name, presence: true
  validates :catalog_price, presence: true
  validates :wholesale_price, presence: true
  validates :catalog_price, numericality: { :greater_than_or_equal_to => :wholesale_price }
  validates :wholesale_price, numericality: { :less_than_or_equal_to => :catalog_price }

  attr_accessible :vendor, :model, :marketing_name, :catalog_price, :wholesale_price, :fd_insured_value, :device_type,
                  :fd_replacement_value, :fd_koil_invoice_value, :yop_insured_value, :yop_replacement_value,
                  :yop_fd_koil_invoice_value, :prev_insured_value, :prev_replacement_value, :prev_fd_koil_invoice_value

  scope :device_similar_to, (lambda do |vendor, model, marketing_name|
    {:conditions => [ "lower(vendor) like ? and (lower(model) like ? or lower(marketing_name) like ? )", "#{!vendor.nil? ? vendor.downcase : '%'}", "#{!model.nil? ? model.downcase : '%'}", "#{!marketing_name.nil? ? marketing_name.downcase : '%'}" ]}
  end )

  scope :wider_search, (lambda do |model|
    {:conditions => [ "lower(model) like ?", "%#{!model.nil? ? model.downcase : '%'}%"]}

  end )

  def get_insurance_value (code, year_of_purchase)
    if !code.nil? && code.starts_with?("FX")
      return fd_insured_value
    elsif year_of_purchase == Time.now.year
      return yop_insured_value
    else
      return prev_insured_value
    end
  end

  def self.get_marketing_search_parameter (term)
    if !term.nil?
      escaped_term = term.gsub! /\s+/, '%'
      return "%#{escaped_term}%" if !escaped_term.nil?
    end
    return ""
  end
end
