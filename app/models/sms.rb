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

class Sms < ActiveRecord::Base
  attr_accessible :text, :to, :request, :response, :receipt_id, :delivered, :time_of_delivery
end
