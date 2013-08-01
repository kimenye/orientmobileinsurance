class Payment < ActiveRecord::Base
  belongs_to :policy
  attr_accessible :amount, :method, :reference, :status, :policy_id

  def for
    policy.policy_number
  end

  def customer
    policy.customer
  end
end
