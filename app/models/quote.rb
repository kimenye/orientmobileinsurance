class Quote < ActiveRecord::Base
  belongs_to :insured_device
  belongs_to :agent
  belongs_to :customer
  has_many :policies
  attr_accessible :account_name, :annual_premium, :expiry_date, :monthly_premium, :insured_device_id, :premium_type, :insured_value, :agent_id, :quote_type, :customer_id


  def name
    account_name
  end


  def policy
    policies.first
  end

  def amount_due
    if premium_type == "Monthly"
      return monthly_premium.to_f * 3
    else
      return annual_premium
    end
  end
  
  def minimum_due
    if is_installment?
      return monthly_premium.to_f
    else
      return annual_premium
    end
  end
  
  def is_installment?
    premium_type == "Monthly"
  end

  def agent_code
    return agent.code if !agent.nil?
  end

  # def customer
  #   if policy.nil?
  #     return ""
  #   else
  #     policy.customer.name
  #   end
  # end

  def is_expired
    expired = expiry_date - Time.now < 0
  end
end
