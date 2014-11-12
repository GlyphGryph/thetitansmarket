class CreateCharacterBodyParts < ActiveRecord::Migration
  def change
    create_table :character_body_parts do |t|
      t.integer :character_id
      t.string :body_part_id
    end
  end
end
