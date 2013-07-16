class CreateEnquiry < ActiveRecord::Migration
  def change
    create_table(:enquiries) do |t|
      t.string "phone_number"
      t.string "text"
      t.string "date_of_enquiry"
      t.string "source"
      t.string "sales_agent_code"
      t.string "agent_id"
      t.string "year_of_purchase"
      t.string "url"
      t.string "hash"
      t.string "detected_device_id"
      t.string "undetected_device_id"
      t.timestamps
    end
  end
end
