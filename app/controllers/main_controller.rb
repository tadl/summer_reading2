class MainController < ApplicationController
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
    params[:participant][:library_card] = _normalize_card(params[:participant][:library_card])
  	@participant = Participant.new(participant_params)
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
  	@weeks = Week.all
    @from_patron = false
  	respond_to do |format|
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
      if match_participant_with_cards(participant_id) != false
       @okay_to_save = true
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
    if cookies[:token]
      @participants = get_cards_from_token()
    else
      @participants = []
    end
    respond_to do |format|
      format.html {render :layout => "frame"}
      format.json {render :json => {:participants => @participants}}
    end
  end

  def patron_load_report_interface
    @today = Date.today
    participant_id = params[:participant_id].to_i
    @participant = match_participant_with_cards(participant_id)
    @weeks = Week.all
    @from_patron = true
    respond_to do |format|
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
        @stats[s[:text] + ' requested at ' + l[:text]] = @participants.where(shirt_size: s[:value]).count.to_s + ' requested and ' + @participants.where(shirt_size: s[:value], got_shirt: false).count.to_s + ' not picked up'
      end
    end
    respond_to do |format|
      format.html
      format.json {render :json => @stats}
    end
  end

  def weekly_reports
    @weeks = Week.all
    if params[:week]
      @week = params[:week]
    else
      @week = '1'
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
    @participants = @participants.joins(:reports).where('week_id = ?', @week).where.not("grand_prize_monday = ? AND monday = ? AND tuesday = ? AND wednesday = ? AND thursday = ? AND friday = ? AND saturday = ? AND sunday = ?", 0,0,0,0,0,0,0,0 )
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
    if !@location && !@club
      @participants = Participant.all.where(inactive: false).includes(:reports)
    elsif @location && @club
      @participants = Participant.all.where(club: @club, home_library: @location, inactive: false).includes(:reports)
    elsif @location
      @participants = Participant.all.where(home_library: @location, inactive: false).includes(:reports)
    elsif @club
      @participants = Participant.all.where(club: @club, inactive: false).includes(:reports)
    end
    @all_partcipants_count = @participants.count 
    @eligible_participants = @participants.select {|p| p.total_minutes >= 600}
    @eligible_participants_count = @eligible_participants.count
    @percent_eligible = ((@eligible_participants_count.to_f / (@all_partcipants_count.to_f)) * 100).round(2).to_s + '%'
    @random_winner = @eligible_participants.sample
    respond_to do |format|
      format.html
      format.json {render :json => {:random_winner => @random_winner, :percent_eligible =>  @percent_eligible, :all_eligible => @eligible_participants}}
    end
  end

  def leaders
    @page = false
    @weeks = Week.all
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
      @week = params[:week]
      @participants = @participants.sort_by {|p| p.weekly_minutes(@week)}
      # Start goofiness to add weekly_minutes to participants hash
      participants_array = Array.new
      @participants.reverse.first(15).each do |p|
        p_hash = p.as_json
        p_hash['weekly_minutes'] = p.weekly_minutes(@week)
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
  
  private

	def participant_params
  	params.require(:participant).permit(:first_name, :last_name, :club, :school, :home_library, :phone_number, :library_card, :middle_name, :email_address, :school, :send_to_school, :got_shirt, :shirt_size)
	end

	def search_by_name_params
		params.require(:name)
	end

	def search_by_card_params
		params.require(:card)
	end

  def get_cards_from_token()
    token = cookies[:token]
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

  def match_participant_with_cards(participant_id)
    @participants = get_cards_from_token()
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