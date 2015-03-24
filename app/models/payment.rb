# == Schema Information
#
# Table name: payments
#
#  id         :integer          not null, primary key
#  policy_id  :integer
#  reference  :string(255)
#  amount     :decimal(, )
#  status     :string(255)
#  method     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  quote_id   :integer
#

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
