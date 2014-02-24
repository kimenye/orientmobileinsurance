class ProductQuote < ActiveRecord::Base
  belongs_to :product
  belongs_to :quote
  belongs_to :product_quote
  attr_accessible :status, :product_id, :quote_id, :price, :product_serial_id
end
