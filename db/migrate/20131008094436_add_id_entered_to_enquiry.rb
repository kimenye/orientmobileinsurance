class AddIdEnteredToEnquiry < ActiveRecord::Migration
  def change
    add_column :enquiries, :id_entered, :boolean
  end
end
