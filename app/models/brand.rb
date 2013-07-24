class Brand < ActiveRecord::Base

  validates :town_name, presence: true

  attr_accessible :town_name, :brand_1, :brand_2, :brand_3, :brand_4

end
