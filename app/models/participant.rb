class Participant < ActiveRecord::Base
	include ActiveModel
	include PgSearch
	pg_search_scope :search_by_name, :against =>[:first_name, :last_name],  :using => { :tsearch => {:prefix => true}}
	pg_search_scope :search_by_card, :against =>[:library_card]
	validates_presence_of :first_name, :last_name, :club, :home_library, :phone_number
	has_many :reports, dependent: :destroy
	has_many :items, dependent: :destroy
	self.per_page = 10

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
			minutes += r.monday.to_i 
			minutes += r.tuesday.to_i 
			minutes += r.wednesday.to_i 
			minutes += r.thursday.to_i 
			minutes += r.friday.to_i 
			minutes += r.saturday.to_i 
			minutes += r.sunday.to_i 
			minutes += r.grand_prize_monday.to_i 
		end
		return minutes
	end

	def weekly_minutes(week_id)
		minutes = 0
		self.reports.each do |r|
			if r.week_id.to_i == week_id.to_i 
				minutes += r.monday.to_i 
				minutes += r.tuesday.to_i 
				minutes += r.wednesday.to_i 
				minutes += r.thursday.to_i 
				minutes += r.friday.to_i 
				minutes += r.saturday.to_i 
				minutes += r.sunday.to_i 
				minutes += r.grand_prize_monday.to_i
			end 
		end
		# minutes = Participant.find(id).reports.where('week_id = ?', week_id).pluck(:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :grand_prize_monday).map(&:compact).map(&:sum).sum
		return minutes
	end

end
