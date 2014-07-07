class AddEmailToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :encrypted_password
      t.string :email
    end
  end
end
