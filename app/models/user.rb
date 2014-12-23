require 'net/http'
require 'json'

class User < ActiveRecord::Base
  validates :first_name, :uid, :last_name, :email, :access_token, :expires_at, :image_url, :refresh_token, presence: true
  validates :email, :uid, uniqueness: { case_sensitive: false }
  
  # Class methods
  def self.find_or_create_from_google_callback omniauth_callback
    auth_cred = omniauth_callback['credentials']
    auth_info = omniauth_callback['info']

    auth = {
      first_name: auth_info['first_name'],
      last_name: auth_info['last_name'],
      email: auth_info['email'],
      uid: omniauth_callback['uid'].to_s,
      image_url: auth_info['image'],
      access_token: auth_cred['token'],
      refresh_token: auth_cred['refresh_token'],
      expires_at: Time.at(auth_cred['expires_at']).to_datetime
    }

     
    if (user = User.find_by_uid auth[:uid])
      user.update_attributes auth
      user
    else
      User.create! auth
    end
  end

# --------------------------------
# UNUSED AND UNTESTED METHODS
# --------------------------------

  def to_params
    {
      'refresh_token' => refresh_token,
      'client_id' => ENV['CLIENT_ID'],
      'client_secret' => ENV['CLIENT_SECRET'],
      'grant_type' => 'refresh_token'
    }
  end


  def request_token_from_google
    url = URI('https://accounts.google.com/o/oauth2/token')
    NET::HTTP.post_form(url, self.to_params)
  end

  def refresh!
    response = request_token_from_google
    data = JSON.parse(response.body)
    update_attributes(
      access_token: data['access_token'],
      expires_at: Time.now + (data['expires_in'].to_i).seconds
    )
  end

  def expired?
    expires_at < Time.now
  end

  def fresh_token
    refresh! if expired?
    access_token
  end

end
