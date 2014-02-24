# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product_serial do
    serial "MyString"
    product nil
  end
end
