# == Schema Information
#
# Table name: messages
#
#  id           :integer          not null, primary key
#  phone_number :string(255)
#  text         :string(255)
#  message_type :integer
#  status       :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    phone_number "+254722200200"
    text "OMI"
    message_type 1
    status "Sent"
  end
end
