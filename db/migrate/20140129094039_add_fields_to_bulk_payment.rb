class AddFieldsToBulkPayment < ActiveRecord::Migration
  def change
    add_column :bulk_payments, :email, :string
    add_column :bulk_payments, :phone_number, :string
  end
end
