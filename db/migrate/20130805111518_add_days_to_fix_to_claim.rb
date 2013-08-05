class AddDaysToFixToClaim < ActiveRecord::Migration
  def change
    add_column :claims, :days_to_fix, :integer
  end
end
