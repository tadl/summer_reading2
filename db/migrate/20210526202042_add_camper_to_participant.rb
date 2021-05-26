class AddCamperToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :camper, :boolean, :default => false
  end
end
