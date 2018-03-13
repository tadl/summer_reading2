class MainController < ApplicationController
	before_filter :shared_variables
  before_filter :set_cache_buster
  before_action :authenticate_admin!, :except => [:index, :register_participant]
  respond_to :html, :json, :js

  def index
  end

  def register_participant
  end

  def save_new_participant
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
    @participant.library_card =params[:library_card]
    @participant.club = params[:club]
    @participant.school = params[:school]
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

  def list_participants
  	if params[:location] && params[:location] != 'all'
  		@location = params[:location]
  	end
  	if params[:club] && params[:club] != 'all'
  		@club = params[:club]
  	end
    @inactive = params[:inactive]
    if @inactive == 'true'
      @participants = Participant.all.where(inactive: true).page params[:page]
  	elsif !@location && !@club
  		@participants = Participant.all.where(inactive: false).page params[:page]
  	elsif @location && @club
  		@participants = Participant.all.where(club: @club, home_library: @location, inactive: false).page params[:page]
  	elsif @location
  		@participants = Participant.all.where(home_library: @location, inactive: false).page params[:page]
  	elsif @club
  		@participants = Participant.all.where(club: @club, inactive: false).page params[:page]
  	end
  			
  	@count = @participants.count
  end

  def search_by_name
  	@query = params[:name]
  	@participants = Participant.search_by_name(search_by_name_params).where.not(inactive: true).page params[:page]
  end

  def search_by_card
  	@query = params[:card]
  	@participants = Participant.search_by_card(search_by_card_params).where.not(inactive: true).page params[:page]
  end

  def load_report_interface
  	participant_id = params[:participant_id].to_i
  	@participant = Participant.includes(:reports, :items).find(participant_id)
  	@weeks = Week.all
  	respond_to do |format|
  		format.js
  	end
  end

  def record_minutes
    @reporting_days.each do |d|
      report = Report.where(participant_id: params[:participant_id], week_id: params[:week_id], day_of_week: d).first
      if report != nil 
        if params[d]
          report.minutes = params[d] 
          report.save
        end
      else
        if params[d]
          report = Report.new
          report.day_of_week = d
          report.participant_id = params[:participant_id]
          report.week_id = params[:week_id]
          report.minutes = params[d]
          report.save
        end
      end
    end
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
    @week = Week.find(params[:week_id])
    respond_to do |format|
      format.js
    end
  end
  
  private

	def participant_params
  	params.require(:participant).permit(:first_name, :last_name, :club, :school, :home_library, :phone_number, :library_card, :middle_name, :email_address, :school)
	end

	def search_by_name_params
		params.require(:name)
	end

	def search_by_card_params
		params.require(:card)
	end

end
