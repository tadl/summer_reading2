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

  def as_json(options={})
    options[:methods] = [:week_total]
    super
  end

end
