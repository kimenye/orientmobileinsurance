class AddAdditionalPriceFieldsToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :fd_insured_value, :decimal
    add_column :devices, :fd_replacement_value, :decimal
    add_column :devices, :fd_koil_invoice_value, :decimal
    add_column :devices, :yop_insured_value, :decimal
    add_column :devices, :yop_replacement_value, :decimal
    add_column :devices, :yop_fd_koil_invoice_value, :decimal
    add_column :devices, :prev_insured_value, :decimal
    add_column :devices, :prev_replacement_value, :decimal
    add_column :devices, :prev_fd_koil_invoice_value, :decimal
    add_column :devices, :device_type, :string
  end
end
