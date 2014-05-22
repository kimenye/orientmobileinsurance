class AddDiscountToAgent < ActiveRecord::Migration
  def change
    add_column :agents, :discount, :float
  end
end
