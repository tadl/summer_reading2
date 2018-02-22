class Participant < ActiveRecord::Base
	include ActiveModel
	validates_presence_of :first_name, :last_name, :club, :home_library, :phone_number
end
