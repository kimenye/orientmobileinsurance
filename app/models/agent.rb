class Agent < ActiveRecord::Base

  validates :town, presence: true
  validates :brand, presence: true
  validates :code, presence: true
  validates :outlet, presence: true
  validates :location, presence: true
  validates :outlet_name, presence: true

  attr_accessible :town, :brand, :outlet, :location, :code, :email, :phone_number, :outlet_name

end
