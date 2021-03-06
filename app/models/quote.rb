# == Schema Information
#
# Table name: quotes
#
#  id                :integer          not null, primary key
#  insured_device_id :integer
#  annual_premium    :decimal(, )
#  monthly_premium   :decimal(, )
#  account_name      :string(255)
#  premium_type      :string(255)
#  expiry_date       :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  insured_value     :decimal(, )
#  agent_id          :integer
#  quote_type        :string(255)
#  customer_id       :integer
#  enquiry_id        :integer
#

class Quote < ActiveRecord::Base


  scope :corporate, where(:quote_type => "Corporate")
  scope :individual, where(:quote_type => "Individual")
  scope :all, where("")

  belongs_to :insured_device
  belongs_to :agent
  belongs_to :customer
  belongs_to :enquiry
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

  # def amount_due
  #   if premium_type == "Monthly"
  #     return monthly_premium.to_f * 3
  #   else
  #     return annual_premium
  #   end
  # end

  def amount_due
    if premium_type == "Monthly"
      return monthly_premium.to_f * 3
    elsif premium_type == "six_monthly"
      return monthly_premium.to_f * 6
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

  def is_airtel?
    enquiry && enquiry.is_airtel?
  end
  
  def is_installment?
    premium_type == "Monthly" || premium_type == "six_monthly"
  end

  def is_corporate?
    quote_type == "Corporate"
  end

  def agent_code
    return agent.code if !agent.nil?
  end

  def is_expired?
    expired = expiry_date - Time.now < 0
  end

  
end
