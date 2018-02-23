class MainController < ApplicationController
	before_filter :shared_variables
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
  	@participants = Participant.all
  end

  def search_by_name
  	@query = params[:name]
  	@participants = Participant.search_by_name(search_by_name_params).where.not(inactive: true).page params[:page]
  end

  def search_by_card
  end

  
  private

	def participant_params
  	params.require(:participant).permit(:first_name, :last_name, :club, :school, :home_library, :phone_number, :library_card, :middle_name, :email_address, :school)
	end

	def search_by_name_params
		params.require(:name)
	end

end
