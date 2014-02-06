require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "Serial number should be unique" do
    Product.delete_all
    Product.create! serial: "JDK9203", price: 3000, name: "Norton Internet Security"
    product = Product.new serial: "JDK9203", price: 3000, name: "Norton Internet Security"
    assert_equal false, product.valid?
  end

  test "Serial number should be entered" do
    product = Product.new price: 3000, name: "dsfdsf"
    assert !product.save
    assert !product.errors[:serial].empty?

  end

  test "Price should be entered" do
    product = Product.new name: "dfd", serial: "sdfdfds"
    assert !product.save
    assert !product.errors[:price].empty?
  end

  test "Name should be entered" do
    product = Product.new price: 3000, serial: "dzgsdg"
    assert !product.save
    assert !product.errors[:name].empty?
  end
end
