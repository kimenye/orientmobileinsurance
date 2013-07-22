class CreatePolicies < ActiveRecord::Migration
  def change
    create_table :policies do |t|
      t.references :quote
      t.string :status
      t.string :policy_number
      t.timestamp :start_date
      t.timestamp :expiry

      t.timestamps
    end
    add_index :policies, :quote_id
  end
end
