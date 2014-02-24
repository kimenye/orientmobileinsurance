class CreateProductSerials < ActiveRecord::Migration
  def change
    create_table :product_serials do |t|
      t.string :serial
      t.references :product

      t.timestamps
    end
    add_index :product_serials, :product_id
  end
end
