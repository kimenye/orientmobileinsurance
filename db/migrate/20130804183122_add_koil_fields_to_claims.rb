class AddKoilFieldsToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :authorized, :boolean
    add_column :claims, :replacement_limit, :decimal
    add_column :claims, :decline_reason, :text
  end
end
