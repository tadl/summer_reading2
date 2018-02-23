module MainHelper
	def filter_select_helper(selection, value)
		if selection == value
			return 'selected'
		else
			return ''
		end
	end
end
