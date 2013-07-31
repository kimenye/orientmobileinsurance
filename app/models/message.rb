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
