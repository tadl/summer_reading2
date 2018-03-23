class AddSendToSchoolParticipants < ActiveRecord::Migration
  def change
  	add_column :participants, :send_to_school, :boolean, :default => false
  end
end
