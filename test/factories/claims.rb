# == Schema Information
#
# Table name: claims
#
#  id                   :integer          not null, primary key
#  claim_no             :string(255)
#  incident_date        :datetime
#  policy_id            :integer
#  claim_type           :string(255)
#  contact_number       :string(255)
#  contact_email        :string(255)
#  incident_description :text
#  status               :string(255)
#  status_description   :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  nearest_town         :string(255)
#  step                 :integer
#  visible_damage       :string(255)
#  type_of_liquid       :string(255)
#  incident_location    :string(255)
#  q_1                  :string(255)
#  q_2                  :string(255)
#  q_3                  :string(255)
#  q_4                  :string(255)
#  q_5                  :string(255)
#  agent_id             :integer
#  police_abstract      :boolean
#  receipt              :boolean
#  original_id          :boolean
#  copy_id              :boolean
#  blocking_request     :boolean
#  dealer_description   :string(255)
#  dealer_can_fix       :boolean
#  dealer_cost_estimate :decimal(, )
#  time_duration        :datetime
#  damaged_device       :boolean
#  authorized           :boolean
#  replacement_limit    :decimal(, )
#  decline_reason       :text
#  days_to_fix          :integer
#  repair_limit         :decimal(, )
#  authorization_type   :string(255)
#  settlement_date      :datetime
#

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
