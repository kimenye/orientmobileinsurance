class AddQuoteTypeToQuote < ActiveRecord::Migration
  def change
    add_column :quotes, :quote_type, :string
  end
end
