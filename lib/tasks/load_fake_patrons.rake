desc "seed_database_with_fake_patrons"
task :load_fake_patrons => :environment do
    require 'faker'
    puts 'creating fake patrons...'
    home_libraries = [
        {value: 'Woodmere', text: 'Woodmere', code: '23'},
        {value: 'Kingsley', text: 'Kingsley', code: '25'},
        {value: 'Interlochen', text: 'Interlochen', code: '24'},
        {value: 'Fife Lake', text: 'Fife Lake', code: '27'},
        {value: 'East Bay', text: 'East Bay', code: '28'},
        {value: 'Peninsula', text: 'Peninsula', code: '26'}
    ]
    teen_schools = [
        { text: 'Central High School' , value:'Central High School'}, 
        { text: 'TBA Career Tech Center' , value:'TBA Career Tech Center'}, 
        { text: 'East Middle School' , value:'East Middle School'}, 
        { text: 'Kitchi Minogining Tribal School' , value:'Kitchi Minogining Tribal School'}, 
        { text: 'Northwest Michigan House of Hope', value:'Northwest Michigan House of Hope'},
        { text: 'Pathfinder School' , value:'Pathfinder School'},
        { text: 'St. Elizabeth Ann Seton Middle School' , value:'St. Elizabeth Ann Seton Middle School'}, 
        { text: 'St. Francis High School' , value:'St. Francis High School'}, 
        { text: 'Traverse City Christian School' , value:'Traverse City Christian School'}, 
        { text: 'Traverse Bay Mennonite School' , value:'Traverse Bay Mennonite School'}, 
        { text: 'Traverse City College Preparatory Academy' , value:'Traverse City College Preparatory Academy'},
        { text: 'Traverse City High School', value:'Traverse City High School'},
        { text: 'Traverse City Seventh-Day Advent' , value:'Traverse City Seventh-Day Advent'},
        { text: 'West Middle School', value:'West Middle School'},
        { text: 'West Senior High', value:'West Senior High'},
        { text: 'Forest Area Middle School' , value:'Forest Area Middle School'},
        { text: 'Forest Area High School' , value:'Forest Area High School'}, 
        { text: 'Kingsley Area Middle School' , value:'Kingsley Area Middle School'}, 
        { text: 'Kingsley Area High School', value:'Kingsley Area High School'}, 
        { text: "St. Mary's of Hannah" , value:"St. Mary's of Hannah"}, 
        { text: 'Greenspire School' , value:'Greenspire School'}, 
        { text: 'Woodland School' , value:'Woodland School'}, 
        { text: 'New Campus' , value:'New Campus'}, 
        { text: 'Grand Traverse Academy' , value:'Grand Traverse Academy'}, 
        { text: 'Other' , value:'Other'}, 
        { text: 'Home School', value:'Home School'}, 
        { text: 'Buckley Comm. Schools', value:'Buckley Comm. Schools'}, 
        { text: 'Traverse City Christian School' , value:'Traverse City Christian School'}
    ].sort_by!{ |e| e[:text].downcase }
    youth_schools = [
        { text: 'Blair' , value: 'Blair'},
        { text: 'Central Grade School' , value: 'Central Grade School'},
        { text: 'Mill Creek Elementary' , value: 'Mill Creek Elementary'},
        { text: 'East Middle School' , value: 'East Middle School'},
        { text: 'International School at Bertha Vos' , value: 'International School at Bertha Vos'},
        { text: 'Cherry Knoll' , value: 'Cherry Knoll'},
        { text: 'Courtade Elementary' , value: 'Courtade Elementary'},
        { text: 'Eastern', value: 'Eastern'},
        { text: 'Holy Angels' , value: 'Holy Angels'},
        { text: 'Immaculate Conception Elementary' , value: 'Immaculate Conception Elementary'},
        { text: 'Long Lake' , value: 'Long Lake'},
        { text: 'Northwest Michigan House of Hope' , value: 'Northwest Michigan House of Hope'},
        { text: 'Old Mission Peninsula' , value: 'Old Mission Peninsula'},
        { text: 'Pathfinder School' , value: 'Pathfinder School'},
        { text: 'Silver Lake', value: 'Silver Lake'},
        { text: 'St. Elizabeth Ann Seton Middle School' , value: 'St. Elizabeth Ann Seton Middle School'},
        { text: 'Oak Park' , value: 'Oak Park'},
        { text: 'TBA SE Early Childhood' , value: 'TBA SE Early Childhood'},
        { text: 'TCAPS Montessori School' , value: 'TCAPS Montessori School'},
        { text: "The Children's House" , value: "The Children's House"},
        { text: 'Traverse Bay Christian School' , value: 'Traverse Bay Christian School'},
        { text: 'Traverse Bay Mennonite School' , value: 'Traverse Bay Mennonite School'},
        { text: 'Traverse City Seventh-Day Advent', value: 'Traverse City Seventh-Day Advent'},
        { text: 'Traverse Heights Elementary School' , value: 'Traverse Heights Elementary School'},
        { text: 'Trinity Lutheran', value: 'Trinity Lutheran'},
        { text: 'West Middle School' , value: 'West Middle School'},
        { text: 'Westwoods' , value: 'Westwoods'},
        { text: 'Willow Hill' , value: 'Willow Hill'},
        { text: 'Woodland School', value: 'Woodland School'},
        { text: 'Forest Area Elementary' , value: 'Forest Area Elementary'},
        { text: 'Forest Area Middle School', value: 'Forest Area Middle School'},
        { text: 'Interlochen Elementary' , value: 'Interlochen Elementary'},
        { text: 'Kingsley Area Elementary' , value: 'Kingsley Area Elementary'},
        { text: 'Kingsley Area Middle School', value: 'Kingsley Area Middle School'},
        { text: 'Lake Ann Elementary', value: 'Lake Ann Elementary'},
        { text: "St. Mary's of Hannah" , value: "St. Mary's of Hannah"},
        { text: 'Grand Traverse Academy' , value: 'Grand Traverse Academy'},
        { text: 'Greenspire School' , value: 'Greenspire School'},
        { text: 'New Campus', value: 'New Campus'},
        { text: 'Other' , value: 'Other'},
        { text: 'Home School' , value: 'Home School'},
        { text: 'Buckley Comm. Schools' , value: 'Buckley Comm. Schools'},
        { text: 'Traverse City Christian School' , value: 'Traverse City Christian School'}
    ].sort_by!{ |e| e[:text].downcase }
    clubs = [
        'pre-readers',
        'readers',
        'teens',
        'adults',
    ]
    shirt_sizes = [
      {value: 'Youth Small', text: 'Youth Small', code: 'Youth Small'},
      {value: 'Youth Medium', text: 'Youth Medium', code: 'Youth Medium'},
      {value: 'Youth Large', text: 'Youth Large', code: 'Youth Large'},
      {value: 'Youth Extra Large', text: 'Youth Extra Large', code: 'Youth Extra Large'},
      {value: 'Adult Small', text: 'Adult Small', code: 'Adult Small'},
      {value: 'Adult Medium', text: 'Adult Medium', code: 'Adult Medium'},
      {value: 'Adult Large', text: 'Adult Large', code: 'Adult Large'},
      {value: 'Adult Extra Large', text: 'Adult Extra Large', code: 'Adult Extra Large'},
    ]
    i = 5000
    @weeks = Week.all
    while i > 0
        @participant = Participant.new
        @participant.first_name = Faker::Name.first_name
        @participant.last_name = Faker::Name.last_name
        @participant.middle_name = Faker::Name.first_name
        @participant.phone_number = Faker::PhoneNumber.phone_number
        @participant.email_address = Faker::Internet.email(@participant.first_name + ' ' + @participant.last_name)
        @participant.home_library = home_libraries.sample[:value]
        @participant.shirt_size = shirt_sizes.sample[:value]
        @participant.library_card = rand.to_s[2..11]
        @participant.club = clubs.sample
        if @participant.club == 'readers'
            @participant.school = youth_schools.sample[:value]
        end
        if @participant.club == 'teens'
            @participant.school = teen_schools.sample[:value]
            send_random = rand(1..4)
            if send_random = 2
                @participant.send_to_school = true
            end
        end
        @participant.save!
        puts 'Just saved ' + @participant.first_name + ' ' + @participant.last_name
        @weeks.each do |w|
            random = rand(1...4)
            if @participant.club != 'pre-readers'
                if random == 2
                    report = Report.new
                    report.participant_id = @participant.id
                    report.week_id = w.id
                    report.monday = rand(10...120)
                    report.tuesday = rand(10...120)
                    report.thursday = rand(10...120)
                    report.wednesday = rand(10...120)
                    report.friday = rand(10...120)
                    report.saturday = rand(10...120)
                    report.sunday = rand(10...120)
                    report.save!
                    item = Item.new
                    item.name = Faker::Book.title
                    item.participant_id = @participant.id
                    item.week_id = w.id
                    item.save!
                end
            else
                if random == (2 || 4)
                    report = Report.new
                    report.participant_id = @participant.id
                    report.week_id = w.id
                    report.monday = rand(1...4) * 10
                    report.tuesday = rand(1...4) * 10
                    report.thursday = rand(1...4) * 10
                    report.wednesday = rand(1...4) * 10
                    report.friday = rand(1...4) * 10
                    report.save!
                    item = Item.new
                    item.name = Faker::Book.title
                    item.participant_id = @participant.id
                    item.week_id = w.id
                    item.save!
                end
            end
        end
        i -= 1
    end
end