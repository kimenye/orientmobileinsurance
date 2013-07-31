class InsuredDevice < ActiveRecord::Base
  belongs_to :customer
  belongs_to :device
  has_many :quotes

  attr_accessible :customer_id, :device_id, :imei

  def quote
    quotes.first
  end

  def name
    "#{customer.name} - #{device.marketing_name}"
  end
end
