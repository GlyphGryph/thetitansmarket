class AddSeasonIdToWorld < ActiveRecord::Migration
  def change
    add_column :worlds, :season_id, :string
  end
end
