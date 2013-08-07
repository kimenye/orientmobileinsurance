class AddYearOfPurchaseToInsuredDevice < ActiveRecord::Migration
  def change
    add_column :insured_devices, :yop, :integer
  end
end
