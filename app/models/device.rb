class Device < ActiveRecord::Base

  validates :vendor, presence: true
  validates :model, presence: true
  validates :marketing_name, presence: true
  validates :catalog_price, presence: true
  validates :wholesale_price, presence: true
  validates :catalog_price, numericality: { :greater_than_or_equal_to => :wholesale_price }
  validates :wholesale_price, numericality: { :less_than_or_equal_to => :catalog_price }

  attr_accessible :vendor, :model, :marketing_name, :catalog_price, :wholesale_price

end
