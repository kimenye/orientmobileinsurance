class ProductQuote < ActiveRecord::Base
  belongs_to :product
  belongs_to :quote
  attr_accessible :status
end
