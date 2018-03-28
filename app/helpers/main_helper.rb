module MainHelper
	def filter_select_helper(selection, value)
		if selection == value
			return 'selected'
		else
			return ''
		end
	end

	def show_minutes_for(participant, week_number, day_name)
		participant.reports.each do |r|
			if r.week_id == week_number && r.day_of_week == day_name
				return r.minutes
			end
		end
	end

	def show_items_for(participant, week_number)
		participant.items.each do |i|
			if i.week_id == week_number
				return i.name
			end
		end
	end
end
