class AddIncidentLocationToClaim < ActiveRecord::Migration
  def change
    add_column :claims, :incident_location, :string
  end
end
