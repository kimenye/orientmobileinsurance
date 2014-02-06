class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :serial
      t.decimal :price
      t.string :name

      t.timestamps
    end
  end
end
