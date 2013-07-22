class Policy < ActiveRecord::Base
  belongs_to :quote
  attr_accessible :expiry, :policy_number, :start_date, :status, :quote_id
end
