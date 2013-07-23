class Policy < ActiveRecord::Base
  belongs_to :quote
  attr_accessible :expiry, :policy_number, :start_date, :status, :quote_id

  def is_open_for_claim
    days_after_start = Time.now - start_date
    is_not_expired = expiry - Time.now > 0

    if days_after_start < 21
      return false
    else
      return true && is_not_expired
    end
  end
end
