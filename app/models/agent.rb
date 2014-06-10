class Agent < ActiveRecord::Base

  validates :outlet_name, presence: true

  attr_accessible :town, :brand, :outlet, :location, :code, :email, :phone_number, :outlet_name, :tag, :discount

  def is_stl
  	code.start_with?("STL")
  end

  def display_name
    "#{code} - #{outlet_name}"
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
