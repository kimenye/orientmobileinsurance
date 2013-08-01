class AddQuestionsToClaim < ActiveRecord::Migration
  def change
    add_column :claims, :q_1, :string
    add_column :claims, :q_2, :string
    add_column :claims, :q_3, :string
    add_column :claims, :q_4, :string
    add_column :claims, :q_5, :string
  end
end
