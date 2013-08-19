class AddHashedTimeStampToEnquiry < ActiveRecord::Migration
  def change
    add_column :enquiries, :hashed_timestamp, :string
  end
end
