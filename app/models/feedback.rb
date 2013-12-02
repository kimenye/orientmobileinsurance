require 'valid_email'
class Feedback < ActiveRecord::Base
  attr_accessible :email, :message, :name

  validates :email, email: :true, presence: :true
  validates :message, presence: :true
  validates :name, presence: :true
end
