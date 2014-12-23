class SessionsController < ApplicationController
  layout false

  def new
  end

  def create
    raise "Missing parameters" if request.nil?
    raise "Missing parameters" if request.env.nil?
    
    auth_cred = request.env['omniauth.auth']['credentials']
    auth_info = request.env['omniauth.auth']['info']

    @auth = {
      first_name: auth_info['first_name'],
      last_name: auth_info['last_name'],
      email: auth_info['email'],
      uid: request.env['omniauth.auth']['uid'].to_s,
      image_url: auth_info['image'],
      access_token: auth_cred['token'],
      refresh_token: auth_cred['refresh_token'],
      expires_at: Time.at(auth_cred['expires_at']).to_datetime
    }

    # raise "foo"
    User.create(@auth)

  end

  # Called from Omniauth initializer (config/initializers/omniauth.rb)
  def oauth_failure
    # TODO: Render something appropriate here
    render text:"failed..."
  end
end
