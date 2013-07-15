class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :phone_number
      t.string :text
      t.integer :message_type
      t.string :status

      t.timestamps
    end
  end
end
