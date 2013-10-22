class Payment < ActiveRecord::Base
  belongs_to :policy
  attr_accessible :amount, :method, :reference, :status, :policy_id

  def for
    policy.policy_number
  end
  
  def device
    policy.quote.insured_device
  end

  def account
    policy.quote.account_name
  end

  def customer
    policy.customer
  end
end
