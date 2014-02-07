# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product_quote do
    status "MyString"
    product nil
    quote nil
  end
end
