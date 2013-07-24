class AddAlternatePhoneNumberToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :alternate_phone_number, :string
  end
end
