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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :insured_device do
    customer nil
    device nil
  end
end
