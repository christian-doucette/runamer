class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.integer :user_id
      t.string :access_token
      t.string :refresh_token
      t.time :token_exp_date

      t.timestamps
    end
  end
end
