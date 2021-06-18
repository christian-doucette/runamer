class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.integer :client_id
      t.string :client_secret
      t.string :access_token
      t.string :refresh_token
      t.datetime :token_exp_date

      t.timestamps
    end
  end
end
