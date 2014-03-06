class InsuredDevice < ActiveRecord::Base
  belongs_to :customer
  belongs_to :device
  has_many :quotes

  attr_accessible :customer_id, :device_id, :imei, :yop, :phone_number, :damaged_flag, :damage_reported, :insurance_value, :replacement_value, :premium_value, :quote_id

  def quote
    quotes.first
  end

  def can_claim?
    !quote.policy.nil? && quote.policy.is_active?
  end

  def has_policy?
    !quote.policy.nil?
  end

  def model
    device.marketing_name
  end

  def name
    "#{customer.name} - #{device.marketing_name} - #{imei}"
  end
end
