# == Schema Information
#
# Table name: subscriptions
#
#  id         :integer          not null, primary key
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'valid_email'

class Subscription < ActiveRecord::Base
  attr_accessible :email
  validates :email, email: :true, presence: :true, uniqueness: :true
end
