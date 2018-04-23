class AddTShirtSize < ActiveRecord::Migration
  def change
  	add_column :participants, :got_shirt, :boolean, :default => false
  	add_column :participants, :shirt_size, :string
  end
end
