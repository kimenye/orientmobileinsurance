class AddCustomerIdToEnquiry < ActiveRecord::Migration
  def change
  	unless column_exists? :enquiries, :customer_id
    	add_column :enquiries, :customer_id, :string
    end
  end
end
