# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product do
    serial "MyString"
    price "9.99"
    name "MyString"
  end
end
