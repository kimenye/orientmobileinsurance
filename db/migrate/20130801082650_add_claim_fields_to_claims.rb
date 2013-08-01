class AddClaimFieldsToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :police_abstract, :boolean
    add_column :claims, :receipt, :boolean
    add_column :claims, :original_id, :boolean
    add_column :claims, :copy_id, :boolean
    add_column :claims, :blocking_request, :boolean
    add_column :claims, :dealer_description, :string
    add_column :claims, :dealer_can_fix, :boolean
    add_column :claims, :dealer_cost_estimate, :decimal
  end
end
