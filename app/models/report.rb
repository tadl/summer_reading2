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
    if self.week_total >= 100
      badge = week.name + '_' + self.participant.club + '_' + '100.png'
      badges.push(badge)
    end
    if self.week_total >= 300
      badge = week.name + '_' + self.participant.club + '_' + '300.png'
      badges.push(badge)
    end
    return badges
  end

  def as_json(options={})
    options[:methods] = [:week_total, :badges]
    super
  end

end
