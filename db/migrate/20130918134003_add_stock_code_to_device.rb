class AddStockCodeToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :stock_code, :string
  end
end
