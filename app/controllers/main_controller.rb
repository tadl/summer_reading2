class MainController < ApplicationController
  require 'net/http'
	before_filter :shared_variables
  before_filter :set_cache_buster
  before_action :authenticate_user!, :except => [:index, :register_participant, :patron_check_for_participants, :patron_show_participants, :patron_load_report_interface, :record_minutes, :patron_register_participant, :save_new_participant, :shirt_stats]
  after_action :allow_iframe, :only => [:patron_show_participants, :patron_load_report_interface, :record_minutes, :patron_register_participant]
  respond_to :html, :json, :js

  def index
  end

  def register_participant
  end

  def save_new_participant
    if params[:v] == '5'
      params[:participant] = params
      puts "got hereeeeee"
    end
    params[:participant][:library_card] = _normalize_card(params[:participant][:library_card])
  	@participant = Participant.new(participant_params)
  	if @participant.valid?
  		@participant.save
  		@message = 'success'
  	else
  		@message = 'fail'
  	end
  	respond_to do |format|
  		format.json {render :json => {:message => @message, :participant   => @participant}}
  	end
  end

  def edit_participant
    @participant = Participant.find(params[:id])
  end

  def update_participant
    @participant = Participant.find(params[:id])
    @participant.first_name = params[:first_name]
    @participant.last_name = params[:last_name]
    @participant.middle_name = params[:middle_name]
    @participant.phone_number = params[:phone_number]
    @participant.email_address = params[:email_address]
    @participant.home_library = params[:home_library]
    @participant.library_card = _normalize_card(params[:library_card])
    @participant.club = params[:club]
    @participant.school = params[:school]
    @participant.send_to_school = params[:send_to_school]
    @participant.shirt_size = params[:shirt_size]
    @participant.teen_challenge = params[:teen_challenge]
    @participant.wants_craft_kit = params[:wants_craft_kit]
    if @participant.valid?
      @participant.save
      @message = 'success'
    else
      @message = 'fail'
    end
    respond_to do |format|
      format.json {render :json => {:message => @message}}
    end
  end

  def set_inactive
    @participant = Participant.find(params[:id])
    @participant.inactive = params[:inactive].to_bool
    @participant.save
    respond_to do |format|
      format.js
    end
  end

  def mark_got_shirt
    if params[:id]
      @participant = Participant.find(params[:id])
      @participant.got_shirt = params[:got_shirt].to_bool
      @participant.save
      @message = "success"
    else
      @message = "error: no participant_id provided"
    end
    respond_to do |format|
      format.json {render :json => {:message => @message}}
    end
  end

  def list_participants
  	if params[:location] && params[:location] != 'all'
  		@location = params[:location]
  	end
  	if params[:club] && params[:club] != 'all'
  		@club = params[:club]
  	end
    @inactive = params[:inactive]
    if @inactive == 'true'
      @participants = Participant.all.where(inactive: true)
  	elsif !@location && !@club
  		@participants = Participant.all.where(inactive: false)
  	elsif @location && @club
  		@participants = Participant.all.where(club: @club, home_library: @location, inactive: false)
  	elsif @location
  		@participants = Participant.all.where(home_library: @location, inactive: false)
  	elsif @club
  		@participants = Participant.all.where(club: @club, inactive: false)
  	end	
  	@count = @participants.count
    @total_minutes = @participants.all.joins(:reports).pluck(:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :grand_prize_monday).map(&:compact).map(&:sum).sum
    # @participants_unpaged is for exporting all patricipants for xlsx view where paging isnt a thing
    @participants_unpaged = @participants
    @participants = @participants.order('updated_at DESC').page params[:page]
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def search_by_name
  	@query = params[:name]
  	@participants = Participant.search_by_name(search_by_name_params).where.not(inactive: true).page params[:page]
  end

  def search_by_card
    params[:card] = _normalize_card(params[:card])
  	@participants = Participant.search_by_card(search_by_card_params).where.not(inactive: true).page params[:page]
  end

  def load_report_interface
    @today = Date.today
  	participant_id = params[:participant_id].to_i
  	@participant = Participant.includes(:reports, :items).find(participant_id)
  	@weeks = Week.all.order('start_date ASC')
    @from_patron = false
  	respond_to do |format|
      format.json {render :json => {:participant => @participant, :reports => @participant.reports, :items => @participant.items, :weeks=> @weeks}}
  		format.js
  	end
  end

  def record_minutes
    @okay_to_save = false
    @week = Week.find(params[:week_id])
    @from_patron = params[:from_patron]
    if current_user
      @okay_to_save = true
    elsif params[:from_patron]
      participant_id = params[:participant_id].to_i
      if params[:token] 
        if match_participant_with_cards(participant_id, params[:token]) != false
          @okay_to_save = true
        end
      else
        if match_participant_with_cards(participant_id, cookies[:token]) != false
          @okay_to_save = true
        end
      end
    end
    if @okay_to_save == true
      report = Report.where(participant_id: params[:participant_id], week_id: params[:week_id]).first
      if report == nil 
        report = Report.new
      end
      report.participant_id = params[:participant_id]
      report.week_id = params[:week_id]
      report.monday = params[:monday]
      report.tuesday = params[:tuesday]
      report.wednesday = params[:wednesday]
      report.thursday = params[:thursday]
      report.friday = params[:friday]
      report.saturday = params[:saturday]
      report.sunday = params[:sunday]
      report.grand_prize_monday = params[:grand_prize_monday]   
      report.save
      if params[:item]
        item = Item.where(participant_id: params[:participant_id], week_id: params[:week_id]).first
        if item != nil 
          item.name = params[:item]
          item.save
        else
          item = Item.new
          item.name = params[:item]
          item.participant_id = params[:participant_id]
          item.week_id = params[:week_id]
          item.save
        end
      end
      @participant = Participant.find(params[:participant_id])
    end
    respond_to do |format|
      format.json {render :json => {:success => @okay_to_save}}
      format.js
    end
  end

  def patron_register_participant
    if params[:user_info] && params[:user_info] != 'undefined'
      user_info = JSON.parse(params[:user_info])
      @card = user_info['card']
      @home_library = user_info['pickup_library']
    end
    respond_to do |format|
      format.html {render :layout => "frame"}
    end
  end

  def patron_check_for_participants
    if params[:cards] && params[:secret] == ENV['ILS_SECRET']
      cards = params[:cards].gsub('"','').gsub('[','').gsub(']','').split(',')
      i = 0
      cards.each do |c|
        if i == 0
          if Participant.search_by_card(c).where.not(inactive: true).size != 0
            i = 1
          end
        end
      end
      if i == 1
        message = "true"
      else
        message = "no participant found with this card"
      end
    else
      message = "invalid request"
    end
    respond_to do |format|
      format.json {render :json => {:message => message}}
    end
  end

  def patron_show_participants
    if params[:token]
      cookies[:token] = params[:token]
    end
    if cookies[:token] || params[:token]
      token = cookies[:token] || params[:token]
      @participants = get_cards_from_token(token)
    else
      @participants = []
    end
    respond_to do |format|
      format.html {render :layout => "frame"}
      format.json {render :json => {:participants => @participants, :teen_schools => @teen_schools, :youth_schools => @youth_schools}}
    end
  end

  def patron_load_report_interface
    @today = Date.today
    participant_id = params[:participant_id].to_i
    token = cookies[:token] || params[:token]
    @participant = match_participant_with_cards(participant_id, token)
    @weeks = Week.all.order('start_date ASC')
    @from_patron = true
    respond_to do |format|
      format.json {render :json => {:participant => @participant, :reports => @participant.reports, :items => @participant.items, :weeks=> @weeks}}
      format.html {render :layout => "frame"}
    end
  end

  def stats
    @stats = Hash.new
    @participants = Participant.all.where(inactive: false).includes(:reports)
    @stats['total_participats'] = @participants.count
    @stats['total_minutes'] = @participants.joins(:reports).pluck(:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :grand_prize_monday).map(&:compact).map(&:sum).sum
    respond_to do |format|
      format.json {render :json => @stats}
    end
  end

  def shirt_stats
    @stats = Hash.new
    @participants = Participant.all.where(inactive: false)
    @home_libraries.drop(1).each do |l|
      @shirt_sizes_raw.reverse.drop(1).each do |s|
        @stats[s[:text] + ' requested at ' + l[:text]] = @participants.where(shirt_size: s[:value], home_library: l[:value]).count.to_s + ' requested and ' + @participants.where(shirt_size: s[:value], home_library: l[:value], got_shirt: false).count.to_s + ' not picked up'
      end
    end
    respond_to do |format|
      format.html
      format.json {render :json => @stats}
    end
  end

  def weekly_reports
    @weeks = Week.all.order('start_date ASC')
    if params[:week]
      @week = Week.find(params[:week])
    else
      @week = Week.where("start_date <= ? AND end_date >= ?", Date.today.to_date, Date.today.to_date).first
      if @week.nil?
        @week = Week.last
      end 
    end
    @page = false
    if params[:location] && params[:location] != 'all'
      @location = params[:location]
    end
    if params[:club] && params[:club] != 'all'
      @club = params[:club]
    end
    if !@location && !@club
      @participants = Participant.all.where(inactive: false)
    elsif @location && @club
      @participants = Participant.all.where(club: @club, home_library: @location, inactive: false)
    elsif @location
      @participants = Participant.all.where(home_library: @location, inactive: false)
    elsif @club
      @participants = Participant.all.where(club: @club, inactive: false)
    end 
    @participants = @participants.joins(:reports).where('week_id = ?', @week.id).where.not("grand_prize_monday = ? AND monday = ? AND tuesday = ? AND wednesday = ? AND thursday = ? AND friday = ? AND saturday = ? AND sunday = ?", 0,0,0,0,0,0,0,0 )
    @random_winner = @participants.sample
    respond_to do |format|
      format.html
      format.json {render :json => {:random_winner => @random_winner, :all_eligible => @participants}}
      format.xlsx
    end
  end

  def final_reports
    @page = false
    if params[:location] && params[:location] != 'all'
      @location = params[:location]
    end
    if params[:club] && params[:club] != 'all'
      @club = params[:club]
    end
    if @location == 'East Bay and Woodmere'
      if @club
        @participants = Participant.all.where(club: @club, home_library: ['East Bay', 'Woodmere'], inactive: false).includes(:reports)
      else
        @participants = Participant.all.where(home_library: ['East Bay', 'Woodmere'], inactive: false).includes(:reports)
      end
    elsif !@location && !@club
      @participants = Participant.all.where(inactive: false).includes(:reports)
    elsif @location && @club
      @participants = Participant.all.where(club: @club, home_library: @location, inactive: false).includes(:reports)
    elsif @location
      @participants = Participant.all.where(home_library: @location, inactive: false).includes(:reports)
    elsif @club
      @participants = Participant.all.where(club: @club, inactive: false).includes(:reports)
    end          
    @home_libraries_filter = @home_libraries_filter.push({value: 'East Bay and Woodmere', text: 'East Bay and Woodmere', code: '42'})
    @all_partcipants_count = @participants.count 
    @eligible_participants = @participants.select {|p| p.total_minutes >= 600}
    if @club == 'teens'
      if @location
        Participant.all.where(club: 'teens', teen_challenge: true, inactive: false, home_library: @location).includes(:reports).each do |p|
          @eligible_participants.push(p)
        end
      else
        Participant.all.where(club: 'teens', teen_challenge: true, inactive: false).includes(:reports).each do |p|
          @eligible_participants.push(p)
        end
      end
      puts 'Total names in hat = ' + @eligible_participants.count.to_s
    end
    @eligible_participants_count = @eligible_participants.uniq.count
    puts 'Uniqenames in hat = ' + @eligible_participants.uniq.count.to_s
    @percent_eligible = ((@eligible_participants_count.to_f / (@all_partcipants_count.to_f)) * 100).round(2).to_s + '%'
    @random_winner = @eligible_participants.sample
    respond_to do |format|
      format.html
      format.json {render :json => {:random_winner => @random_winner, :percent_eligible =>  @percent_eligible, :all_eligible => @eligible_participants.uniq}}
      format.xlsx
    end
  end

  def send_to_school_report
    @participants = Participant.all.where(inactive: false, send_to_school: true).includes(:reports)
    respond_to do |format|
      format.json {render :json => @participants}
      format.xlsx
    end
  end


  def school_totals_report
    @club = params[:club]
    @participants = Participant.all.where(inactive: false, club: @club).includes(:reports)
    @schools = []
    @participants.each do |p|
      school = p.school
      if !school.nil?
        if @schools.all?{|h| h[school].nil? } == true
          school_location = {}
          school_location[school] = {}
          school_location[school]['count'] = 1
          school_location[school]['total_minutes'] = p.total_minutes
          @schools.push(school_location)
        else
          school_location = @schools.find{|h| h[school]}
          school_location[school]['count'] += 1
          school_location[school]['total_minutes'] += p.total_minutes
        end
      end
    end
    respond_to do |format|
      format.json {render :json => @schools}
      format.xlsx
    end
  end
  
  def registrations_report
    if params[:club] && params[:club] != 'all'
      @club = params[:club]
    end
    if params[:location] && params[:location] != 'all'
      @location = params[:location]
    end
    if !@club && !@location
      @title = "Registration and Reporting Data for All Locations"
      @participants = Participant.where(inactive: false).includes(:reports)
    elsif @location && @club
      @title = "Registration and Reporting Data for " + params[:club].capitalize + ' at ' + params[:location]
      @participants = Participant.where(club: params[:club], home_library: params[:location], inactive: false).includes(:reports)
    elsif @location
      @title = "Registration and Reporting Data at " + params[:location]
      @participants = Participant.where(home_library: params[:location], inactive: false).includes(:reports)
    elsif @club
      @title = "Registration and Reporting Data for " + params[:club].capitalize
      @participants = Participant.where(club: params[:club], inactive: false).includes(:reports)
    end 
    weeks = Week.all.order(:start_date)
    @list_of_weeks = []
    pre_registration = {}
    pre_registration[:name] = "pre-registration"
    pre_register_count = 0
    @participants.each do |p|
      if p.created_at < weeks[0].start_date
        pre_register_count +=1
      end
    end
    pre_registration[:registrations] = pre_register_count
    @list_of_weeks.push(pre_registration)
    weeks.each do |w|
      week = {}
      week[:name] = w.name
      week[:start_date] = w.start_date
      week[:end_date] = w.end_date
      registrations = 0
      @participants.each do |p|
        if p.created_at > w.start_date && p.created_at < w.end_date.end_of_day
          registrations += 1
        end
      end 
      week[:registrations] = registrations
      weekly_minutes = 0
      total_minutes_so_far = 0
      reports_so_far = []
      if @participants
        @participants.each do |p|
          p.reports.each do |r|
            if r.created_at < w.end_date.end_of_day
              reports_so_far.push(r)
            end
            if r.week_id == w.id
              weekly_minutes += r.week_total
            end
          end
        end
        reports_so_far.each do |r|
          total_minutes_so_far += r.week_total
        end
      end
      week[:weekly_minutes] = weekly_minutes
      week[:total_minutes_so_far] = total_minutes_so_far 
      @list_of_weeks.push(week)
    end
    @club = params[:club]
    @location = params[:location]    
    respond_to do |format|
      format.html
      format.json {render :json => {:title => @title, :registration_data => @list_of_weeks}}
    end
  end

  def year_end_reports
    @weeks = [*1..7]
    @clubs = ['pre-readers','readers','teens','adults']
    @libraries =['All','Woodmere','Kingsley','Interlochen','Fife Lake','East Bay','Peninsula']
    @report = {}
    @libraries.each do |l|
      if l == 'All' 
        participants = Participant.all.where(inactive: false).includes(:reports)
      else
        participants = Participant.all.where(inactive: false, home_library: l).includes(:reports)
      end
      @report[l] = {}
      @report[l]['all_count'] = participants.count
      @report[l]['all_minutes'] = 0
      participants.each do |p|
        @report[l]['all_minutes'] += p.total_minutes
      end
      @clubs.each do |c|
        @report[l][c+'_count'] = participants.where(club: c).count
        @report[l][c+'_minutes'] = 0
        participants.where(club: c).each do |p|
          @report[l][c+'_minutes'] += p.total_minutes
        end
        @report[l][c+'_winners'] = participants.where(club: c).select {|p| p.total_minutes >= 600}.count
      end
      @report[l]['all_winners'] = participants.select {|p| p.total_minutes >= 600}.count
      @weeks.each do |w|
        week_name = 'Week ' + w.to_s
        week_id = Week.where(name: week_name).first.id
        @report[l]['week_'+w.to_s] = {}
        @report[l]['week_'+w.to_s]['all_reports'] = participants.select {|p| p.weekly_minutes(week_id) > 0}.count
        @report[l]['week_'+w.to_s]['all_minutes'] = 0
        participants.each do |p|
          @report[l]['week_'+w.to_s]['all_minutes'] += p.weekly_minutes(week_id)
        end
        @clubs.each do |c|
          @report[l]['week_'+w.to_s][c+'_reports'] = participants.where(club: c).select {|p| p.weekly_minutes(week_id) > 0}.count
          @report[l]['week_'+w.to_s][c+'_minutes'] = 0
          participants.where(club: c).each do |p|
            @report[l]['week_'+w.to_s][c+'_minutes'] += p.weekly_minutes(week_id)
          end
        end
      end
    end
    respond_to do |format|
      format.json {render :json => @report}
      format.xlsx
    end
  end

  def leaders
    @page = false
    @weeks = Week.all.order('start_date ASC')
    if params[:location] && params[:location] != 'all'
      @location = params[:location]
    end
    if params[:club] && params[:club] != 'all'
      @club = params[:club]
    end
    if !@location && !@club
      @participants = Participant.all.where(inactive: false).includes(:reports)
    elsif @location && @club
      @participants = Participant.all.where(club: @club, home_library: @location, inactive: false).includes(:reports)
    elsif @location
      @participants = Participant.all.where(home_library: @location, inactive: false).includes(:reports)
    elsif @club
      @participants = Participant.all.where(club: @club, inactive: false).includes(:reports)
    end
    if params[:week]
      @week = Week.find(params[:week])
      @participants = @participants.sort_by {|p| p.weekly_minutes(@week.id)}
      # Start goofiness to add weekly_minutes to participants hash
      participants_array = Array.new
      @participants.reverse.first(15).each do |p|
        p_hash = p.as_json
        p_hash['weekly_minutes'] = p.weekly_minutes(@week.id)
        participants_array.push(p_hash)
      end
      @participants = @participants.reverse.first(15)
      @participant_json = participants_array.to_json
      #end goofiness
    else
      @participants = @participants.sort_by {|p| p.total_minutes}
      @participants = @participants.reverse.first(15)
      @participants_json = @participants.to_json({:methods => :total_minutes})
    end
    respond_to do |format|
      format.html
      format.json {render :json => @participants_json }
    end  
  end

  def get_eg_data
    if params[:card]
      @user = data_from_card(params[:card])
    else
      @user = false
    end
    respond_to do |format|
      format.js 
    end
  end
  
  private

	def participant_params
  	params.require(:participant).permit(:first_name, :wants_craft_kit, :last_name, :club, :school, :home_library, :phone_number, :library_card, :middle_name, :email_address, :school, :send_to_school, :got_shirt, :shirt_size, :teen_challenge)
	end

	def search_by_name_params
		params.require(:name)
	end

	def search_by_card_params
		params.require(:card)
	end

  def get_cards_from_token(token)
    url = 'https://catalog.tadl.org/login.json?token=' + token
    response = JSON.parse(open(url).read)
    if response["cards"]
      @participants = Array.new
      response["cards"].each do |c|
        participants_with_card = Participant.search_by_card(c).where.not(inactive: true).includes(:reports, :items)
        participants_with_card.each do |p|
          @participants.push(p)
        end
      end
    else
      @participants = []
    end
    return @participants
  end

  def match_participant_with_cards(participant_id, token)
    @participants = get_cards_from_token(token)
    @participants.each do |p|
      if p.id == participant_id
        @participant = p
      end
    end
    if @participant
      return @participant
    else
      return false
    end
  end

  def data_from_card(card)
    normalize_card = _normalize_card(card)

    login_params = {}
    login_params[:identifier] = ENV['ILS_ACCOUNT']
    login_params[:password] = ENV['ILS_ACCOUNT_CREDENTIALS']

    url = URI.parse('https://mr-v2.catalog.tadl.org/osrf-gateway-v1')

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(url.request_uri)
    request.set_form_data({
      "service" => "open-ils.auth",
      "method" => "open-ils.auth.login",
      "param" => JSON.generate(login_params)
    })
    make_request = http.request(request)
    response = JSON.parse(make_request.body)
    authtoken = response['payload'][0]['payload']['authtoken']
    formated_auth = ('"' + authtoken  +'"')    
    formated_barcode = ('"' + normalize_card + '"')
    request.set_form_data({
      "service" => "open-ils.actor",
      "method" => "open-ils.actor.user.fleshed.retrieve_by_barcode.authoritative",
      "param" => [formated_auth, formated_barcode]
    })
    make_request = http.request(request)
    response = JSON.parse(make_request.body)
    if response['payload'][0]['textcode'] && response['payload'][0]['textcode'] == 'ACTOR_CARD_NOT_FOUND'
      return false
    else
      user_data = {}
      user_data[:last_name] = response['payload'][0]['__p'][25].to_s
      user_data[:first_name] = response['payload'][0]['__p'][26].to_s
      user_data[:middle_name] = response['payload'][0]['__p'][42].to_s
      user_data[:email] = response['payload'][0]['__p'][22].to_s
      user_data[:home_library] = home_library_code_to_loaction(response['payload'][0]['__p'][27]).to_s
      user_data[:phone] = response['payload'][0]['__p'][20].to_s
      return user_data
    end
  end

  def home_library_code_to_loaction(code)
    target_location = @home_libraries.detect{|k| k[:code] == code.to_s}
    return target_location[:value]
  end

  def _normalize_card(card_value)
    # It is entirely possible that this method belongs somewhere else,
    # with regard to where things "should" go in a Ruby on Rails app

    # accept a value as input which represents a library card number
    # since the value may be supplied by a barcode scanner, we should attempt to
    # normalize the value by lowercasing it, stripping trailing characters, etc

    # Strip any whitespace
    card_value.gsub!(/\s+/, '')

    # Lowercase entire value
    card_value.downcase!

    # Strip trailing digits if this looks like a scanned drivers license or ID
    if (card_value.length == 27 or card_value.length == 25)
      card_value = card_value[0,13].downcase
    else
      if (card_value.length == 23) # Older format State ID cards
        card_value = card_value[0,12].downcase
      end
    end
     return card_value
  end

end