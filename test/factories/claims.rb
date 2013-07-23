# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :claim do
    claim_no "MyString"
    incident_date "2013-07-23 18:35:41"
    policy nil
    claim_type "MyString"
    contact_number "MyString"
    contact_email "MyString"
    incident_description "MyString"
  end
end
