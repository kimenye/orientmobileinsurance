class ChangeYearOfPurchaseToInteger < ActiveRecord::Migration
  def change
    change_column :enquiries, :year_of_purchase, :integer
  end
end
