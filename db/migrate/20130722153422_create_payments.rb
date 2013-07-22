class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :policy
      t.string :reference
      t.decimal :amount
      t.string :status
      t.string :method

      t.timestamps
    end
    add_index :payments, :policy_id
  end
end
