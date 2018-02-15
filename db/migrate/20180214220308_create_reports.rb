class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer :week_id
      t.integer :participant_id
      t.string :day_of_week
      t.integer :minutes

      t.timestamps null: false
    end
  end
end
