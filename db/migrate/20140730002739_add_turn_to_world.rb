class AddTurnToWorld < ActiveRecord::Migration
  def change
    add_column :worlds, :turn, :integer
  end
end
