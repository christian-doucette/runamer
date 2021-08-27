class ChangeUserExpiresAtFromDatetimeToInteger < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :token_exp_date, :integer
  end
end
