class AddHashedPhoneNumberToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :hashed_phone_number, :string
  end
end
