class CreateBulkPayments < ActiveRecord::Migration
  def change
    create_table :bulk_payments do |t|
      t.string :code
      t.string :reference
      t.decimal :amount_required
      t.decimal :amount_paid
      t.string :channel


      t.timestamps
    end
  end
end
