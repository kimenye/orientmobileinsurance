# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sm, :class => 'Sms' do
    to "MyString"
    text "MyString"
  end
end
