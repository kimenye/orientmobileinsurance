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

  def new_claim
    claim = Claim.new
    claim.policy_id = id
    claim
  end

  def name
    policy_number
  end

  def is_pending?
    status == "Pending"
  end

  def is_active?
    status == "Active"
  end

  def is_owing?
    pending_amount > 0
  end

  def payment_due?
    is_pending? && pending_amount > 0
  end

  def status_message
    if status == "Inactive"
      return "Dial *#06# to retrieve the 15-digit IMEI no. of your device. Record this it and SMS the word OMI and the number to #{ENV['SHORT_CODE']} to receive your Orient Mobile policy confirmation."
    elsif status == "Pending"
      pending = ActionController::Base.helpers.number_to_currency(pending_amount, :unit => "KES ", :precision => 0, :delimiter => "")
      return "The Orient Mobile policy for this device has an outstanding balance of #{pending}. Your account no. is #{quote.account_name}. Please pay via MPesa (Business No. #{ENV['MPESA']}) or Airtel Money (Business Name JAMBOPAY).  You can register your claim after payment confirmation."
    end
  end

  def claim
    claims.last
  end

  def premium
    quote.amount_due
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
    #if quote.premium_type == "Monthly"
    #  quote_amount *= 3
    #end

    quote_amount.to_f - amount_paid.to_f
  end

  def insured_device
    quote.insured_device
  end

  def customer
    quote.insured_device.customer
  end
  
  def can_claim?
    is_active? && !is_owing?
  end

  def has_claim?
    !claim.nil?
  end
end
