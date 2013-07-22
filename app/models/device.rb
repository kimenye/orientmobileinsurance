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

  scope :device_similar_to, (lambda do |str|
    {:conditions => [ "lower(model) like ? ", "#{str.downcase}" ]}
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
end
