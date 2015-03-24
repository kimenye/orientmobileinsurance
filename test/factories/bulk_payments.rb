# == Schema Information
#
# Table name: bulk_payments
#
#  id              :integer          not null, primary key
#  code            :string(255)
#  reference       :string(255)
#  amount_required :decimal(, )
#  amount_paid     :decimal(, )
#  channel         :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  email           :string(255)
#  phone_number    :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :bulk_payment do
    code "MyString"
    reference "MyString"
    amount_required "9.99"
    amount_paid "9.99"
    channel "MyString"
  end
end
