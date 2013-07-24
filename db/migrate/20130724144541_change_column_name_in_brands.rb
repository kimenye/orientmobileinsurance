class ChangeColumnNameInBrands < ActiveRecord::Migration
  def change
    remove_column :brands, :name
    add_column :brands, :town_name, :string
    add_column :brands, :brand_1, :string
    add_column :brands, :brand_2, :string
    add_column :brands, :brand_3, :string
    add_column :brands, :brand_4, :string
  end
end
