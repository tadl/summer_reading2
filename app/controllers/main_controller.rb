class MainController < ApplicationController
	before_filter :shared_variables
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
  end

  def report_participant
  end

  def list_participants
  	if params[:location] && params[:location] != 'all'
  		@location = params[:location]
  	end
  	if params[:club] && params[:club] != 'all'
  		@club = params[:club]
  	end
  	if !@location && !@club
  		@participants = Participant.all.page params[:page]
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
  	@participant = Participant.find(participant_id)
  	@weeks = Week.all
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
