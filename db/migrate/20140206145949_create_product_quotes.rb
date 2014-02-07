class CreateProductQuotes < ActiveRecord::Migration
  def change
    create_table :product_quotes do |t|
      t.string :status
      t.references :product
      t.references :quote

      t.timestamps
    end
    add_index :product_quotes, :product_id
    add_index :product_quotes, :quote_id
  end
end
