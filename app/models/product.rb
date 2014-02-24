class Product < ActiveRecord::Base
  attr_accessible :name, :price

  validates :name, presence: true
  validates :price, presence: true

  has_many :product_serials
  has_many :product_quotes
  has_many :quotes, through: :product_quotes
end
