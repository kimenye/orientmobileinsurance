class LinkCustomerToQuote < ActiveRecord::Migration
  def change
    add_column :quotes, :customer_id, :integer
    add_column :insured_devices, :quote_id, :integer
    add_index :quotes, :customer_id
    add_index :insured_devices, :quote_id
  end
end
