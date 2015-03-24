# == Schema Information
#
# Table name: policies
#
#  id                :integer          not null, primary key
#  quote_id          :integer
#  status            :string(255)
#  policy_number     :string(255)
#  start_date        :datetime
#  expiry            :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  insured_device_id :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :policy do
    quote nil
    status "MyString"
    policy_number "MyString"
    start_date "2013-07-22 18:25:12"
    expiry "2013-07-22 18:25:12"
  end
end
