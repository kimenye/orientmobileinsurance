class Enquiry < ActiveRecord::Base

  attr_accessible :phone_number, :text, :date_of_enquiry, :source, :sales_agent_code, :agent_id, :year_of_purchase, :url,
                  :hashed_phone_number, :detected_device_id, :undetected_device_id, :customer_name, :customer_id, :customer_email,
                  :customer_payment_option, :customer_phone_number, :hashed_timestamp, :model, :vendor, :marketing_name, :detected, :user_agent, :id_type

  belongs_to :agent

  #validates :phone_number, presence: true
  #phony_normalize :customer_phone_number, :default_country_code => 'KE'
  validates_plausible_phone :customer_phone_number, :country_code => '254'
  validates :customer_phone_number, length: {is: 12}, allow_blank: true
  #validates :customer_phone_number, :phony_plausible => true
  validates :source, presence: true

  validates_format_of :customer_id, :with => /^[A-Za-z0-9.&]*\z/, if: :is_passport?
  validates :customer_id, numericality: { only_integer: true }, if: :is_id?

  validate :validate_sales_info, on: :update

  def is_id?
    return id_type == "National ID"
  end

  def is_passport?
    return id_type == "Passport"
  end

  def validate_sales_info
    errors.add(:year_of_purchase, "A valid Year of Purchase is required") if year_of_purchase.nil? || year_of_purchase < 1930 || year_of_purchase > Time.now.year
  end

  def after_initialize
    self.customer_name = ''
    self.customer_id = ''
    self.customer_email = ''
    self.customer_payment_option = ''
    self.customer_phone_number = ''
  end

  attr_accessor :customer_name, :customer_id, :customer_email, :customer_payment_option, :customer_phone_number

end
