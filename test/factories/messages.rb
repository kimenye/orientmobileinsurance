# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    phone_number "+254722200200"
    text "OMI"
    message_type 1
    status "Sent"
  end
end
