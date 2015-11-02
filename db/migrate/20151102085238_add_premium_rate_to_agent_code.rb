class AddPremiumRateToAgentCode < ActiveRecord::Migration
  def change
    add_column :agents, :premium_rate, :float
  end
end
