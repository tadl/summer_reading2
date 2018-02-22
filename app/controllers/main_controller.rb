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
  end
  private

	def participant_params
  	params.permit(:first_name, :last_name, :club, :school, :home_library, :phone_number, :library_card, :middle_name, :email_address, :school)
	end

end
