# == Schema Information
#
# Table name: quotes
#
#  id                :integer          not null, primary key
#  insured_device_id :integer
#  annual_premium    :decimal(, )
#  monthly_premium   :decimal(, )
#  account_name      :string(255)
#  premium_type      :string(255)
#  expiry_date       :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  insured_value     :decimal(, )
#  agent_id          :integer
#  quote_type        :string(255)
#  customer_id       :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :quote do
    insured_device nil
    annual_premium "9.99"
    monthly_premium "9.99"
    account_name "MyString"
    expiry_date "2013-07-22 17:56:31"
  end
end
