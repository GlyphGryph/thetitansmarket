class DropAction < ActiveRecord::Migration
  def up
    drop_table :actions
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Can't restore deleted action table."
  end
end
