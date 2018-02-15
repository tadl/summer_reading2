class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.integer :week_id
      t.integer :participant_id

      t.timestamps null: false
    end
  end
end
