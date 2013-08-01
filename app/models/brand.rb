class Brand < ActiveRecord::Base

  validates :town_name, presence: true

  attr_accessible :town_name, :brand_1, :brand_2, :brand_3, :brand_4

  def brands
    brand = brand_1
    if !brand_2.empty?
      brand += ", #{brand_2}"
    end
    if !brand_3.empty?
      brand += ", #{brand_2}"
    end
    if !brand_4.empty?
      brand += ", #{brand_2}"
    end
    brand
  end

end
