class ChangeDataTypeOfClaimIncidentDescription < ActiveRecord::Migration
  def change
  	change_column :claims, :incident_description, :text
  end
end
