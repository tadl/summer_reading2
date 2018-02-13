class AddEmailAndAvatarsToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :avatar, :string
    add_column :admins, :email, :string
  end
end
