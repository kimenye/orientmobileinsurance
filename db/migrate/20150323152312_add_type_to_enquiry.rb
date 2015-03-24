class AddTypeToEnquiry < ActiveRecord::Migration
  def change
    add_column :enquiries, :enquiry_type, :string, default: 'omb'
  end
end
