class Report < ActiveRecord::Base
	belongs_to :participant

  def week_total
    total = 0
    total += self.monday unless self.monday.nil?
    total += self.tuesday unless self.tuesday.nil?
    total += self.wednesday unless self.wednesday.nil?
    total += self.thursday unless self.thursday.nil?
    total += self.friday unless self.friday.nil?
    total += self.saturday unless self.saturday.nil?
    total += self.sunday unless self.sunday.nil?
    return total
  end

  def badges
    badges = []
    week = Week.find(self.week_id)

    # NOTE: ONCE WE CREATE NEW WEEKS WE WILL NEED TO UPDATE THIS. FUTURE VERSION: WEEKS HAVE HAS_BADGE FIELD IN DB
    unless week.name == 'Week 7' || week.name == 'Week 8'
      if self.week_total >= 100
        badge = week.name.downcase.gsub(' ','_') + '.jpg'
        badges.push(badge)
      end
    end
    return badges
  end

  def as_json(options={})
    options[:methods] = [:week_total, :badges]
    super
  end

end
