class AddMonthOfPurchaseToEnquiry < ActiveRecord::Migration
  def change
    add_column :enquiries, :month_of_purchase, :string
  end
end
