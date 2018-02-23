class Participant < ActiveRecord::Base
	include ActiveModel
	include PgSearch
	pg_search_scope :search_by_name, :against =>[:first_name, :last_name],  :using => { :tsearch => {:prefix => true}}
	pg_search_scope :search_by_card, :against =>[:library_card]
	validates_presence_of :first_name, :last_name, :club, :home_library, :phone_number
end
