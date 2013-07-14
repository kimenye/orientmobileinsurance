class CreateAgent < ActiveRecord::Migration
  def change
    create_table(:agents) do |t|
      t.string "town"
      t.string "brand"
      t.string "outlet"
      t.string "location"
      t.string "code"
      t.string "email"
      t.string "phone_number"
      t.timestamps
    end
  end
end
