class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.integer :client_id
      t.integer :client_secret
      t.integer :access_token
      t.integer :refresh_token
      t.datetime :token_exp_date

      t.timestamps
    end
  end
end
