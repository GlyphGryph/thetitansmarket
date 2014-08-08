class AddViewedToProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :viewed_by_receiver, :boolean
    add_column :proposals, :viewed_by_sender, :boolean
  end
end
