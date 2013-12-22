class Brand < ActiveRecord::Base

  validates :town_name, presence: true

  attr_accessible :town_name, :brand_1, :brand_2, :brand_3, :brand_4, :brand_5

  def brands
    brand = brand_1
    if !brand_2.blank?
      brand += ", #{brand_2}"
    end
    if !brand_3.blank?
      brand += ", #{brand_3}"
    end
    if !brand_4.blank?
      brand += ", #{brand_4}"
    end
    brand
  end

end
