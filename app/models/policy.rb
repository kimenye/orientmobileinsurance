class Policy < ActiveRecord::Base
  belongs_to :quote
  has_many :claims
  has_many :payments
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

  def claim
    claims.last
  end

  def amount_paid
    amount_paid = 0
    payments.each do |payment|
      amount_paid += payment.amount.to_f
    end
    amount_paid
  end

  def pending_amount
    quote_amount = quote.amount_due
    if quote.premium_type == "Monthly"
      quote_amount.to_f *= 3
    end

    quote_amount.to_f - amount_paid.to_f
  end

  def insured_device
    quote.insured_device
  end

  def customer
    quote.insured_device.customer
  end

  def has_claim?
    !claim.nil?
  end
end
