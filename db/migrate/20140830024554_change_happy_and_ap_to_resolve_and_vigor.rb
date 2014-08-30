class ChangeHappyAndApToResolveAndVigor < ActiveRecord::Migration
  def change
    rename_column :characters, :ap, :vigor
    rename_column :characters, :max_ap, :max_vigor
    rename_column :characters, :happy, :resolve
    rename_column :characters, :max_happy, :max_resolve
    rename_column :character_actions, :stored_ap, :stored_vigor
  end
end
