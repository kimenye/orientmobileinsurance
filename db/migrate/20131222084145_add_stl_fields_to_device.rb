class AddStlFieldsToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :stl_insured_value, :decimal
    add_column :devices, :stl_replacement_value, :decimal
    add_column :devices, :stl_koil_invoice_value, :decimal
    add_column :devices, :dealer_code, :string
  end
end
