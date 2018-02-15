class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  private
  def current_user
    @current_user ||= Admin.find(session[:user_id]) if session[:user_id]
  end
  def authenticate_user!
    if !current_user
    	redirect_to root_url, :alert => 'You need to sign in for access to this page.'
    end
  end
  def authenticate_admin!
  	if !current_user || current_user.email != ENV['ADMIN_EMAIL']
  		redirect_to root_url, :alert => 'You do not have the right permissions access to the requested page.'
  	end
  end
  def shared_variables
  	@home_libraries = [
  		'Woodmere',
  		'Kingsley',
  		'Interlochen',
  		'Fife Lake',
  		'East Bay',
  		'Peninsula'
  	]
	end
  helper_method :current_user
end
