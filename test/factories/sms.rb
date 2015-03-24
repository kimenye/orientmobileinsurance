# == Schema Information
#
# Table name: sms
#
#  id               :integer          not null, primary key
#  to               :string(255)
#  text             :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  request          :text
#  response         :text
#  receipt_id       :string(255)
#  delivered        :boolean
#  time_of_delivery :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sm, :class => 'Sms' do
    to "MyString"
    text "MyString"
  end
end
