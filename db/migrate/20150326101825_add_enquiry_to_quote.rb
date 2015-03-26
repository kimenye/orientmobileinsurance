class AddEnquiryToQuote < ActiveRecord::Migration
  def change
    add_column :quotes, :enquiry_id, :integer
    add_index :quotes, :enquiry_id
  end
end
