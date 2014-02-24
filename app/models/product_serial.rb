class ProductSerial < ActiveRecord::Base
  belongs_to :product
  attr_accessible :serial, :product_id, :used
  
  # validates :serial, presence: true
  # validates :serial, uniqueness: true
end
