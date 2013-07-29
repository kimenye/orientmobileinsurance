class Quote < ActiveRecord::Base
  belongs_to :insured_device
  has_many :policies
  attr_accessible :account_name, :annual_premium, :expiry_date, :monthly_premium, :insured_device_id, :premium_type, :insured_value

  def policy
    policies.first
  end
end
