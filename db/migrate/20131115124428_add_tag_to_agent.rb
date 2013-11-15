class AddTagToAgent < ActiveRecord::Migration
  def change
    add_column :agents, :tag, :string
  end
end
