require 'net/http'
require 'json'
require 'user_tests'

class User < ActiveRecord::Base
  include UserTests

  validates :uid, :name, :first_name, :last_name, :email, :token, :expires_at, :image, presence: true
  validates :email, :uid, uniqueness: { case_sensitive: false }

  # Ensures a new sharey_session_cookie is generated whenever the user's attributes are updated
  before_validation :generate_session_cookie

  # Class methods
  def self.find_or_create_from_google_callback google_response
    # Check if a User exists
    user = User.find_by uid:google_response[:uid]
    
    return user unless user.nil?

    # Lets extract the parameters we're interested in
    user_params = google_response[:info].merge google_response[:credentials].except(:expires)
    user_params['uid'] = google_response[:uid]

    # Convert expires_at to a Datetime 
    user_params['expires_at'] = Time.at(user_params['expires_at'].to_i).to_datetime

    User.create! user_params
  end


  # def self.find_or_create_from_google_callback omniauth_callback
  #   auth_cred = omniauth_callback['credentials']
  #   auth_info = omniauth_callback['info']

  #   auth = {
  #     first_name: auth_info['first_name'],
  #     last_name: auth_info['last_name'],
  #     email: auth_info['email'],
  #     uid: omniauth_callback['uid'].to_s,
  #     image_url: auth_info['image'],
  #     access_token: auth_cred['token'],
  #     refresh_token: auth_cred['refresh_token'],
  #     expires_at: Time.at(auth_cred['expires_at']).to_datetime
  #   }

     
  #   if (user = User.find_by_uid auth[:uid])
  #     user.update_attributes auth
  #     user
  #   else
  #     User.create! auth
  #   end
  # end

  def refresh_tokens google_response
    new_attributes = google_response.slice(:token, :refresh_token).select do |key,val|
      !val.nil? and !val.empty? and self[key] != val
    end
    self.update_attributes! new_attributes unless new_attributes.empty?
  end

  def generate_session_cookie
    self.sharey_session_cookie = ((0...20).map { (65 + rand(40)).chr }.join + "pam"*5).split("").shuffle.join
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
