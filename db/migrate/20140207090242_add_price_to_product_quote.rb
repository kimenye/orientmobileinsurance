class AddPriceToProductQuote < ActiveRecord::Migration
  def change
    add_column :product_quotes, :price, :decimal
  end
end
