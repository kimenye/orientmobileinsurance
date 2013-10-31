class AddIdEnteredToEnquiry < ActiveRecord::Migration
  def change
    add_column :enquiries, :id_type, :string
    add_column :enquiries, :customer_id, :string
  end
end
