class AddPaymentToQuote < ActiveRecord::Migration
  def change
    add_column :payments, :quote_id, :integer
    add_index :payments, :quote_id
  end
end
