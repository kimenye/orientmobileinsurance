class CreateDealers < ActiveRecord::Migration
  def change
    create_table :dealers do |t|
      t.string :code
      t.string :name
      t.string :sales_code_prefix

      t.timestamps
    end
  end
end
