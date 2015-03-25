# == Schema Information
#
# Table name: agents
#
#  id           :integer          not null, primary key
#  town         :string(255)
#  brand        :string(255)
#  outlet       :string(255)
#  location     :string(255)
#  code         :string(255)
#  email        :string(255)
#  phone_number :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  outlet_name  :string(255)
#  tag          :string(255)
#  discount     :float
#

class Agent < ActiveRecord::Base

  validates :outlet_name, presence: true
  validates :code, presence: true

  attr_accessible :town, :brand, :outlet, :location, :code, :email, :phone_number, :outlet_name, :tag, :discount

  def is_stl
  	code.start_with?("STL")
  end

  def display_name
    "#{code} - #{outlet_name}"
  end

  def is_airtel?
    code == ENV['AIRTEL_CODE']
  end

  def is_fd
  	premium_service = PremiumService.new
  	premium_service.is_fx_code code
  end

  def is_neither_fd_nor_stl
  	!is_stl && !is_fd
  end

  def name
    "#{brand} #{outlet_name}".strip
  end
end
