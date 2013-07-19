class ChangeYearOfPurchaseToInteger < ActiveRecord::Migration
  def change
    remove_column :enquiries, :year_of_purchase
    add_column :enquiries, :year_of_purchase, :integer
  end
end
