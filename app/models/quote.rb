class Quote < ActiveRecord::Base
  belongs_to :insured_device
  has_many :policies
  attr_accessible :account_name, :annual_premium, :expiry_date, :monthly_premium, :insured_device_id, :premium_type, :insured_value

  def policy
    policies.first
  end

  def amount_due
    if premium_type == "Monthly"
      return monthly_premium
    else
      return annual_premium
    end
  end

  def customer
    if policy.nil?
      return ""
    else
      policy.customer.name
    end
  end
end
