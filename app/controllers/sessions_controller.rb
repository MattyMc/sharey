class SessionsController < ApplicationController
  layout false
  before_filter :get_current_user, :only => [:index]

  def index
  end

  # Action catches the callback from Google's API
  def create
    raise "Missing parameters" if request.nil?
    raise "Missing parameters" if request.env.nil?
    
    # raise "foo"
    @current_user = User.find_or_create_from_google_callback(request.env['omniauth.auth'])
    # reset_session
    cookies.permanent[:sharey_session_cookie] = @current_user.sharey_session_cookie
    session['current_user_id'] = @current_user.id

    get_current_user
    redirect_to root_url, :notice => 'Signed in!'
  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'Signed out!'
  end

  # Called from Omniauth initializer (config/initializers/omniauth.rb)
  def oauth_failure
    # TODO: Render something appropriate here
    render text:"failed..."
  end

  def get_current_user
    @current_user ||= current_user
  end
end
