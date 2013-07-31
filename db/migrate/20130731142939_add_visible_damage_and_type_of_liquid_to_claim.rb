class AddVisibleDamageAndTypeOfLiquidToClaim < ActiveRecord::Migration
  def change
    add_column :claims, :visible_damage, :string
    add_column :claims, :type_of_liquid, :string
  end
end
