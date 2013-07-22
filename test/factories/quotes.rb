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
