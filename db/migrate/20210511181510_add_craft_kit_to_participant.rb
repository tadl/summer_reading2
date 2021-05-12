class AddCraftKitToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :wants_craft_kit, :boolean, :default => false
  end
end
