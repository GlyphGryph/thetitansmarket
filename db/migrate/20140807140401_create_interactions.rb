class CreateInteractions < ActiveRecord::Migration
  def change
    create_table :interactions do |t|

      t.timestamps
    end
  end
end
