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
