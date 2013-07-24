class InsuredDevice < ActiveRecord::Base
  belongs_to :customer
  belongs_to :device
  has_many :quotes

  attr_accessible :customer_id, :device_id, :imei
end
