class Payment < ActiveRecord::Base
  belongs_to :policy
  attr_accessible :amount, :method, :reference, :status, :policy_id
end
