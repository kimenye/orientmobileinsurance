# == Schema Information
#
# Table name: payments
#
#  id         :integer          not null, primary key
#  policy_id  :integer
#  reference  :string(255)
#  amount     :decimal(, )
#  status     :string(255)
#  method     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  quote_id   :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment do
    policy nil
    reference "MyString"
    amount "9.99"
    status "MyString"
    method "MyString"
  end
end
