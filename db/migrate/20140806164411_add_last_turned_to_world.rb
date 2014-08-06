class AddLastTurnedToWorld < ActiveRecord::Migration
  def change
    add_column :worlds, :last_turned, :timestamp
  end
end
