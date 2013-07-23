class AddInsuredValueToQuote < ActiveRecord::Migration
  def change
    add_column :quotes, :insured_value, :decimal
  end
end
