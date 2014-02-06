class Product < ActiveRecord::Base
  attr_accessible :name, :price, :serial

  validates :name, presence: true
  validates :price, presence: true
  validates :serial, presence: true
  validates :serial, uniqueness: true
end
