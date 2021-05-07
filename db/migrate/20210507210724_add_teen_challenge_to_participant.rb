class AddTeenChallengeToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :teen_challenge, :boolean, :default => false
  end
end
