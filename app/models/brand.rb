# == Schema Information
#
# Table name: brands
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  town_name  :string(255)
#  brand_1    :string(255)
#  brand_2    :string(255)
#  brand_3    :string(255)
#  brand_4    :string(255)
#  brand_5    :string(255)
#

class Brand < ActiveRecord::Base

  validates :town_name, presence: true

  attr_accessible :town_name, :brand_1, :brand_2, :brand_3, :brand_4, :brand_5

  def name
  end

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

  def is_stl_location
    brand_1 == "Simba Telecom" || brand_2 == "Simba Telecom" || brand_3 == "Simba Telecom" || brand_4 == "Simba Telecom" || brand_5 == "Simba Telecom"
  end

end
