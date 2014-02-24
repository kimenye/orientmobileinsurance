class AddProductSerialIdToProductQuote < ActiveRecord::Migration
  def change
  	add_column :product_quotes, :product_serial_id, :integer
  	add_index :product_quotes, :product_serial_id
  end
end
