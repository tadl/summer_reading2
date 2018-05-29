class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  require 'open-uri'
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
  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
  def shared_variables
  	@raw_home_libraries =[
      'Woodmere', 
      'Kingsley', 
      'Interlochen', 
      'Fife Lake', 
      'East Bay',
      'Peninsula',
    ]

    @home_libraries = [
  		{value: '', text: 'Select Home Library', code: ''},
  		{value: 'Woodmere', text: 'Woodmere', code: '23'},
  		{value: 'Kingsley', text: 'Kingsley', code: '25'},
  		{value: 'Interlochen', text: 'Interlochen', code: '24'},
  		{value: 'Fife Lake', text: 'Fife Lake', code: '27'},
  		{value: 'East Bay', text: 'East Bay', code: '28'},
  		{value: 'Peninsula', text: 'Peninsula', code: '26'}
  	]
    
    @home_libraries_filter = @home_libraries.drop(1).unshift({value: 'all', text: 'All'})
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
    @teen_schools = teen_schools.unshift({value: '', text: 'Select School'})
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
    @youth_schools = youth_schools.unshift({value: '', text: 'Select School'})
    all_schools = (youth_schools + teen_schools).uniq.sort_by!{ |e| e[:text].downcase }
    @all_schools = all_schools.unshift({value: '', text: 'Select School'})
    @clubs = [
      'pre-readers',
      'readers',
      'teens',
      'adults',
    ]
    @shirt_sizes = [
      {value: '', text: 'Select Shirt Size', code: ''},
      {value: 'Youth Extra Small', text: 'Youth Extra Small', code: 'Youth Extra Small'},
      {value: 'Youth Small', text: 'Youth Small', code: 'Youth Small'},
      {value: 'Youth Medium', text: 'Youth Medium', code: 'Youth Medium'},
      {value: 'Youth Large', text: 'Youth Large', code: 'Youth Large'},
      {value: 'Youth Extra Large', text: 'Youth Extra Large', code: 'Youth Extra Large'},
      {value: 'Adult Small', text: 'Adult Small', code: 'Adult Small'},
      {value: 'Adult Medium', text: 'Adult Medium', code: 'Adult Medium'},
      {value: 'Adult Large', text: 'Adult Large', code: 'Adult Large'},
      {value: 'Adult Extra Large', text: 'Adult Extra Large', code: 'Adult Extra Large'},
      {value: 'Adult Double Extra Large', text: 'Adult Double Extra Large', code: 'Adult Double Extra Large'},
    ]
    @shirt_sizes_raw = @shirt_sizes.drop(1)
	end
  def allow_iframe
    response.headers.delete "X-Frame-Options"
  end
  helper_method :current_user
end
