class AddCustomerTypeToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :customer_type, :string
    add_column :customers, :company_name, :string
  end
end
