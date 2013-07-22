# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :insured_device do
    customer nil
    device nil
  end
end
