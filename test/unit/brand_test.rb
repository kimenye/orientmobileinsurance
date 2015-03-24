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

require 'test_helper'
class BrandTest < ActiveSupport::TestCase

	test "A STL location has at least one simba telecom brand" do
		brand = Brand.new({ :brand_1 => "Simba Telecom"})
		assert_equal true, brand.is_stl_location

		brand = Brand.new({ :brand_3 => "Simba Telecom", :brand_1 => "PhoneLink"})
		assert_equal true, brand.is_stl_location

		brand = Brand.new({ :brand_3 => "Fones Direct", :brand_1 => "PhoneLink"})
		assert_equal false, brand.is_stl_location
	end
end
