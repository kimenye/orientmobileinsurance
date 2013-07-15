class CreateDevice < ActiveRecord::Migration
  def change
    create_table(:devices) do |t|
      t.string "vendor"
      t.string "model"
      t.string "marketing_name"
      t.decimal "catalog_price"
      t.decimal "wholesale_price"
      t.timestamps
    end
  end
end
