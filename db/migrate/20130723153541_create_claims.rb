class CreateClaims < ActiveRecord::Migration
  def change
    create_table :claims do |t|
      t.string :claim_no
      t.timestamp :incident_date
      t.references :policy
      t.string :claim_type
      t.string :contact_number
      t.string :contact_email
      t.string :incident_description
      t.string :status
      t.string :status_description

      t.timestamps
    end
    add_index :claims, :policy_id
  end
end
