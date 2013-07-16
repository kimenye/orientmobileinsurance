class ChangeHashColumnNameInEnquiry < ActiveRecord::Migration
  def change
    rename_column :enquiries, :hash, :hashed_phone_number
  end
end
