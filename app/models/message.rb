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

class Message < ActiveRecord::Base
  attr_accessible :phone_number, :status, :text, :message_type

  validates :phone_number, presence: true
  validates :status, presence: true
  validates :message_type, presence: true

  def kind
    if message_type == 1
      return "OMI Enquiry"
    elsif message_type == 2
      return "IMEI"
    else
      return "Unknown"
    end
  end
end
