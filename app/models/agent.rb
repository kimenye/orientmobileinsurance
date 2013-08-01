class Agent < ActiveRecord::Base

  validates :outlet_name, presence: true

  attr_accessible :town, :brand, :outlet, :location, :code, :email, :phone_number, :outlet_name


  def name
    "#{brand} #{outlet_name}"
  end
end
