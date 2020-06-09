module MainHelper
	def filter_select_helper(selection, value)
		if selection == value
			return 'selected'
		else
			return ''
		end
	end

	def show_minutes_for(participant, week_number)
		participant.reports.each do |r|
			if r.week_id == week_number 
				return r
			end
		end
		return Report.new
	end

	def show_items_for(participant, week_number)
		participant.items.each do |i|
			if i.week_id == week_number
				return i.name
			end
		end
		return ''
	end

  def get_bages_for(week_id, participant)
    reports = participant.reports
    badges = nil
    reports.each do |r|
      if r.week_id == week_id
        badges = r.badges
      end
    end
    return badges
  end
end
