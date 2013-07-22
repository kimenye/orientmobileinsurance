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
