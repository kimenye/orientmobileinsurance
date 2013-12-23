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