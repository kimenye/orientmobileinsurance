class AddFieldsToClaim < ActiveRecord::Migration
  def change
    add_column :claims, :nearest_town, :string
    add_column :claims, :step, :integer
  end
end
