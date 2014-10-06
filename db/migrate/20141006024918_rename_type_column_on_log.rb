class RenameTypeColumnOnLog < ActiveRecord::Migration
  def change
    rename_column :log_entries, :type, :status
  end
end
