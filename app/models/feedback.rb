# == Schema Information
#
# Table name: feedbacks
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  message    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'valid_email'
class Feedback < ActiveRecord::Base
  attr_accessible :email, :message, :name

  validates :email, email: :true, presence: :true
  validates :message, presence: :true
  validates :name, presence: :true
end
