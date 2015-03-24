# == Schema Information
#
# Table name: insured_devices
#
#  id                :integer          not null, primary key
#  customer_id       :integer
#  device_id         :integer
#  imei              :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  yop               :integer
#  phone_number      :string(255)
#  damaged_flag      :boolean
#  damage_reported   :datetime
#  insurance_value   :decimal(, )
#  replacement_value :decimal(, )
#  premium_value     :decimal(, )
#  quote_id          :integer
#

class InsuredDevice < ActiveRecord::Base
  before_save :strip_whitespace
  belongs_to :customer
  belongs_to :device
  has_many :quotes

  attr_accessible :customer_id, :device_id, :imei, :yop, :phone_number, :damaged_flag, :damage_reported, :insurance_value, :replacement_value, :premium_value, :quote_id

  def quote
    quotes.first
  end

  def can_claim?
    !quote.policy.nil? && quote.policy.is_active?
  end

  def has_policy?
    !quote.policy.nil?
  end

  def model
    device.marketing_name
  end

  def name
    "#{customer.name} - #{device.marketing_name} - #{imei}"
  end

  private

  def strip_whitespace
    if !phone_number.nil?
      self.phone_number.gsub!(/\s+/, '')
      if !phone_number.starts_with?("+")
        self.phone_number = "+#{self.phone_number}"
      end
    end
  end
end
