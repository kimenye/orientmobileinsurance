class Agent < ActiveRecord::Base

  validates :outlet_name, presence: true

  attr_accessible :town, :brand, :outlet, :location, :code, :email, :phone_number, :outlet_name, :tag

  def is_stl
  	code.start_with?("STL")
  end

  def name
    "#{brand} #{outlet_name}".strip
  end
end
