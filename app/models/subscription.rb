require 'valid_email'

class Subscription < ActiveRecord::Base
  attr_accessible :email
  validates :email, email: :true, presence: :true, uniqueness: :true
end
