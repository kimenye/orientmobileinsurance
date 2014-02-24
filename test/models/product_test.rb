require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "Price should be entered" do
    product = Product.new name: "dfd"
    assert !product.save
    assert !product.errors[:price].empty?
  end

  test "Name should be entered" do
    product = Product.new price: 3000
    assert !product.save
    assert !product.errors[:name].empty?
  end
end
