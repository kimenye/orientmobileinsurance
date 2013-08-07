class AddRepairFieldsForClaims < ActiveRecord::Migration
  def change
    add_column :claims, :repair_limit, :decimal
    add_column :claims, :authorization_type, :string
  end
end
