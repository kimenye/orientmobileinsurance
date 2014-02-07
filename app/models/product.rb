class Product < ActiveRecord::Base
  attr_accessible :name, :price, :serial

  validates :name, presence: true
  validates :price, presence: true
  validates :serial, presence: true
  validates :serial, uniqueness: true

  has_many :product_quotes
  has_many :quotes, through: :product_quotes
end
