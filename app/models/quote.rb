class Quote < ActiveRecord::Base


  scope :corporate, where(:quote_type => "Corporate")
  scope :individual, where(:quote_type => "Individual")
  scope :all, where("")

  belongs_to :insured_device
  belongs_to :agent
  belongs_to :customer
  has_many :policies
  has_many :payments
  attr_accessible :account_name, :annual_premium, :expiry_date, :monthly_premium, :insured_device_id, :premium_type, :insured_value, :agent_id, :quote_type, :customer_id


  def name
    account_name
  end

  def corporate_amount_paid 
    amount = 0
    payments.each do |payment|
      amount += payment.amount
    end
    amount
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

  def payment_option
    if is_installment?
      return "Installment"
    else
      return "Annual"
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

  def is_corporate?
    quote_type == "Corporate"
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
