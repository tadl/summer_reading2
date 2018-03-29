class AddDaysToReports < ActiveRecord::Migration
  def change
  	add_column :reports, :monday, :integer
  	add_column :reports, :tuesday, :integer
  	add_column :reports, :wednesday, :integer
  	add_column :reports, :thursday, :integer
  	add_column :reports, :friday, :integer
  	add_column :reports, :saturday, :integer
  	add_column :reports, :sunday, :integer
  	add_column :reports, :grand_prize_monday, :integer
  end
end
