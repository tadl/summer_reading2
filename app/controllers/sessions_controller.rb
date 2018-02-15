class SessionsController < ApplicationController
  def create
    user = Admin.from_omniauth(env["omniauth.auth"])
    if user != false
    	session[:user_id] = user.id
    	redirect_to root_url
    else
    	redirect_to root_url, :alert => 'Only approved TADL users can login as administrators.'
    end 
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end
end
