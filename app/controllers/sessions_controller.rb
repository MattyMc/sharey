class SessionsController < ApplicationController
  layout false

  def new
  end

  def create
    raise "Missing parameters" if request.nil?
    raise "Missing parameters" if request.env.nil?
    
    # raise "foo"
    @user = User.find_or_create_from_google_callback(request.env['omniauth.auth'])
  end

  # Called from Omniauth initializer (config/initializers/omniauth.rb)
  def oauth_failure
    # TODO: Render something appropriate here
    render text:"failed..."
  end
end
