class AddRawTokenToTokens < ActiveRecord::Migration[5.2]
  def change
    add_column :tokens, :raw_token, :string, unique: true
  end
end
