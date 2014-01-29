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
