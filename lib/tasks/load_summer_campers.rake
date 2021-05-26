desc "load summer campers for csv"
task :load_summer_campers => :environment do
    require 'csv'
    require 'open-uri'
    require 'json'
    CSV.foreach("#{Rails.root}/campers.csv", :encoding => 'bom|utf-8') do |x|
        patron = Participant.new
        full_name = x[0]
        patron.last_name = x[0].split('","')[0]
        patron.first_name = x[0].split('","')[1].split(' ')[0]
        patron.middle_name = x[0].split('","')[1].split(' ')[1]
        patron.phone_number = x[2]
        patron.home_library = "Woodmere"
        patron.club = "readers"
        patron.shirt_size = "No thanks, I don't need a shirt or a patch"
        patron.camper = true
        patron.save
    end
end