class Participant < ActiveRecord::Base
	include ActiveModel
	include PgSearch
	pg_search_scope :search_by_name, :against =>[:first_name, :last_name],  :using => { :tsearch => {:prefix => true}}
	pg_search_scope :search_by_card, :against =>[:library_card]
	validates_presence_of :first_name, :last_name, :club, :home_library, :phone_number
	has_many :reports, dependent: :destroy
	has_many :items, dependent: :destroy
	self.per_page = 5

	def full_name
		full_name = self.first_name
		if self.middle_name
			full_name += ' ' + self.middle_name
		end
		full_name += ' ' + self.last_name
	end

	def total_minutes
		minutes = 0
		self.reports.each do |r|
			if r.minutes != nil
				minutes += r.minutes
			end
		end
		return minutes
	end

end
