class CreateParticipants < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.string :first_name
      t.string :last_name
      t.string :middle_name
      t.string :club
      t.string :grade_level
      t.string :email_address
      t.string :phone_number
      t.string :library_card
      t.boolean :got_packet
      t.boolean :got_final_prize
      t.string :zip_coed
      t.boolean :inactive
      t.string :home_library
      t.string :school

      t.timestamps null: false
    end
  end
end
