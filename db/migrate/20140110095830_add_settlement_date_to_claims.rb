class AddSettlementDateToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :settlement_date, :datetime
  end
end
