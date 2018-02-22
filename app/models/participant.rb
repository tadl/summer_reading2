class Participant < ActiveRecord::Base
	include ActiveModel
	attr_accessor :first_name, :last_name, :club, :school, :home_library, :phone_number, :library_card, :middle_name, :email_address, :school 
	validates_presence_of :first_name, :last_name, :club, :home_library, :phone_number
end
