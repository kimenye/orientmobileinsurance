class CreateSms < ActiveRecord::Migration
  def change
    create_table :sms do |t|
      t.string :to
      t.string :text

      t.timestamps
    end
  end
end
