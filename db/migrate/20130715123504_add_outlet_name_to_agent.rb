class AddOutletNameToAgent < ActiveRecord::Migration
  def change
    add_column :agents, :outlet_name, :string
  end
end
