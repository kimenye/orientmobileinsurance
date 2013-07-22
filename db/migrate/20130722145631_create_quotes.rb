class CreateQuotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.references :insured_device
      t.decimal :annual_premium
      t.decimal :monthly_premium
      t.string :account_name
      t.string :premium_type
      t.timestamp :expiry_date

      t.timestamps
    end
    add_index :quotes, :insured_device_id
  end
end
