class AddUsedToProductSerial < ActiveRecord::Migration
  def change
    add_column :product_serials, :used, :boolean, default: false
  end
end
