class AddABrandToBrand < ActiveRecord::Migration
  def change
    add_column :brands, :brand_5, :string
  end
end
