class Message < ActiveRecord::Base
  attr_accessible :phone_number, :status, :text, :message_type

  validates :phone_number, presence: true
  validates :status, presence: true
  validates :text, presence: true
  validates :message_type, presence: true
end
