class SetInactiveToFalseByDefault < ActiveRecord::Migration
  def change
  	change_column_default(:participants, :inactive, false)
  end
end
