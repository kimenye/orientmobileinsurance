class Policy < ActiveRecord::Base
  scope :pending, where(:status => "Pending")
  scope :active, where("status = ? and start_date <= ? and expiry >= ?", "Active", Time.now, Time.now)
  scope :expired, where("expiry <= ?", Time.now)
  scope :all, where("")
  scope :corporate, lambda { where("quote_type = ?", "Corporate").joins(:quote) }
  scope :individual, lambda { where("quote_type = ?", "Individual").joins(:quote) }

  belongs_to :quote
  belongs_to :insured_device
  has_many :claims
  has_many :payments
  attr_accessible :expiry, :policy_number, :start_date, :status, :quote_id, :insured_device_id, :quote_type
  validates :insured_device_id, presence: true

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

  #TODO: Check expiry dates - needs tests
  def is_active?
    status == "Active"
  end

  def is_owing?
    pending_amount > 0
  end

  def payment_due?
    is_pending? && pending_amount > 0
  end
  
  def minimum_paid
    amount_paid >= quote.minimum_due
  end
  
  def minimum_due
    quote.minimum_due - amount_paid
  end

  def expired
    Time.now > expiry
  end

  def status_message
    if status == "Inactive"
      return "Dial *#06# to retrieve the 15-digit IMEI no. of your device. Record this it and SMS the word OMI and the number to #{ENV['SHORT_CODE']} to receive your Orient Mobile policy confirmation."
    elsif status == "Pending"
      pending = ActionController::Base.helpers.number_to_currency(pending_amount, :unit => "KES ", :precision => 0, :delimiter => "")
      return "The Orient Mobile policy for this device has an outstanding balance of #{pending}. Your account no. is #{quote.account_name}. Please pay via MPesa (Business No. #{ENV['MPESA']}) or Airtel Money (Business Name #{ENV['AIRTEL']}).  You can register your claim after payment confirmation."
    end
  end

  def claim
    claims.last
  end

  def premium
    if !quote.is_corporate? 
      return quote.amount_due
    else 
      return insured_device.premium_value
    end
  end

  def amount_due
    if quote.monthly_premium >= pending_amount
        return quote.monthly_premium
    else
        return pending_amount
    end
  end

  def amount_paid
    amount_paid = 0
    amount_paid = premium if quote.is_corporate?
    
    payments.each do |payment|
      amount_paid += payment.amount.to_f
    end
    amount_paid
  end

  def pending_amount
    quote_amount = quote.amount_due
    quote_amount = premium if quote.is_corporate?
    #if quote.premium_type == "Monthly"
    #  quote_amount *= 3
    #end
    if quote.premium_type == "Prepaid"
        return 0
    else
      quote_amount.to_f - amount_paid.to_f
    end
  end

  def payment_option
    quote.payment_option
  end

  def next_payment_date
    if quote.is_installment?
    else
      return nil
    end
  end

  def sales_agent_code
    if quote.agent.nil?
      return "Direct"
    else
      return quote.agent.code
    end
  end

  def sales_agent_name
    if quote.agent.nil?
      return "Direct"
    else
      return "#{quote.agent.brand} #{quote.agent.outlet_name}"
    end
  end

  # def insured_device
  #   quote.insured_device if !quote.is_corporate?
  # end

  def imei
    if !insured_device.nil?
      return insured_device.imei
    else
      return nil
    end
  end

  def customer
    quote.customer
  end
  
  def can_claim?
    is_active? && !is_owing?
  end

  def has_claim?
    !claim.nil?
  end

  def has_active_claim?
    has_claim? && claim.is_in_customer_stage?
  end
end
