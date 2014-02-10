class AddProductTypeToQuote < ActiveRecord::Migration
  def change
    add_column :quotes, :product_type, :string, default: "Device"
  end
end
