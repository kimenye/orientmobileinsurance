class Payment < ActiveRecord::Base
  belongs_to :policy
  belongs_to :quote
  attr_accessible :amount, :method, :reference, :status, :policy_id, :quote_id

  def for
    policy.policy_number
  end
  
  def device
    quote.insured_device
  end

  def account
    quote.account_name
  end

  def customer
    quote.customer
  end
end
