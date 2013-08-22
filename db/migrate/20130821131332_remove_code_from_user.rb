class RemoveCodeFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :code
  end
end
