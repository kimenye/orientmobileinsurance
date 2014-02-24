class AddDefaultValueToStatus < ActiveRecord::Migration
  def change
  	change_column :product_quotes, :status, :string, :default => "PENDING"
  end
end
