# == Schema Information
#
# Table name: enquiries
#
#  id                   :integer          not null, primary key
#  phone_number         :string(255)
#  text                 :string(255)
#  date_of_enquiry      :string(255)
#  source               :string(255)
#  sales_agent_code     :string(255)
#  url                  :string(255)
#  hashed_phone_number  :string(255)
#  detected_device_id   :string(255)
#  undetected_device_id :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  year_of_purchase     :integer
#  agent_id             :integer
#  hashed_timestamp     :string(255)
#  model                :string(255)
#  vendor               :string(255)
#  marketing_name       :string(255)
#  detected             :boolean
#  user_agent           :string(255)
#  id_type              :string(255)
#  customer_id          :string(255)
#  month_of_purchase    :string(255)
#  enquiry_type         :string(255)      default("omb")
#

class Enquiry < ActiveRecord::Base
  scope :device_detected, where(:detected => true)
  scope :device_not_detected, where(:detected => [false,nil])

  before_save :strip_whitespace
  
  attr_accessible :phone_number, :text, :date_of_enquiry, :source, :sales_agent_code, :agent_id, :year_of_purchase, :month_of_purchase, :url,
                  :hashed_phone_number, :detected_device_id, :undetected_device_id, :customer_name, :customer_id, :customer_email,
                  :customer_payment_option, :customer_phone_number, :hashed_timestamp, :model, :vendor, :marketing_name, :detected, :user_agent, :id_type, :enquiry_type

  belongs_to :agent


  validates_plausible_phone :phone_number, :country_code => '254', on: :update
  # validates :phone_number, length: { in: 12..13 }, allow_blank: false, on: :update
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
    self.customer_email = ''
    self.customer_payment_option = ''
    self.customer_phone_number = ''
  end

  def name
    "Enquiry"
  end

  attr_accessor :customer_name, :customer_email, :customer_payment_option, :customer_phone_number

  private

  def strip_whitespace
    if !phone_number.nil?
      self.phone_number.gsub!(/\s+/, '')
      # if !phone_number.starts_with?("+")
      #   self.phone_number = "+#{self.phone_number}"
      # end
    end
  end

end
