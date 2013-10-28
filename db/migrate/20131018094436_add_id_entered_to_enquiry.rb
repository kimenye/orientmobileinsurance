class AddIdEnteredToEnquiry < ActiveRecord::Migration
  def change
    add_column :enquiries, :id_type, :string
  end
end
