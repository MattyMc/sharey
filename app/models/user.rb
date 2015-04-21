require 'net/http'
require 'json'
require 'user_tests'
require 'custom_errors'

class User < ActiveRecord::Base
  include UserTests
  include CustomErrors

  # Relationships -----------------------------------------------------------------------------
  has_many :items, as: :user
  has_many :friends
  has_many :friends_with_me, class_name: "Friend", as: :receiving_user
  has_many :shared_items, class_name:"Item", foreign_key: "originator_id"
  has_many :categories
  has_many :usage_data, as: :user

  # Validations -------------------------------------------------------------------------------
  validates :uid, :name, :first_name, :last_name, :email, :token, :expires_at, :image, presence: true
  validates :email, :uid, uniqueness: { case_sensitive: false }

  # Filters -----------------------------------------------------------------------------------
  # Ensures a new sharey_session_cookie is generated whenever the user's attributes are updated
  before_validation :generate_session_cookie


  # -------------------------------------------------------------------------------------------
  # Instance methods --------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------
  def destroy_item id
    item = self.items.includes("usage_datum").where(id: id).first # Not using find since it raises an exception
    raise ItemNotFoundForUser if item.nil?
    item.usage_datum.deleted = true

    item.usage_datum.save!
    {"type" => "flash", "data" => {"message" => "Item Deleted"}}
  end

  def name_as_hash
    {"type" => "inline", "data" => {"message" => self.name, "action" => "username"}}
  end

  def get_number_of_unviewed_items
    return UsageDatum.where(user:self, viewed: false).count
  end

  def last_n_items n
    raise NoItemsFound if self.items.count == 0

    # Item.joins(:usage_datum).where(user:u, usage_data: {viewed:true}).limit(1).includes(:category)
    unviewed_items = Item.joins(:usage_datum).where(user: self, usage_data: {viewed: false, deleted: false}).limit(n).includes(:category, :document, :usage_datum)

    if !unviewed_items.nil? and unviewed_items.count == n
      return_items = unviewed_items
    else
      viewed_items = Item.joins(:usage_datum).includes(:category, :document, :usage_datum).where(user: self, usage_data: {viewed: true, deleted: false}).last(n-unviewed_items.count)
      return_items = unviewed_items + viewed_items
    end

    # Get the tags, flatten them
    tags = Friend.where(user: self).pluck("receiving_user_id", "tag").flatten

    # Get the attributes we want
    return_items = return_items.map {|i| 
      { 
        "description" => i.description, 
        "url" => i.document.url, 
        "viewed" => i.usage_datum.viewed,  
        "from_user_tag" => i.from_user_id.nil? ? nil : tags[tags.index(i.from_user_id)+1], 
        "path" => "items/#{i.id}",
        "category_name" => i.category.nil? ? nil : i.category.name,
        "updated_at" => i.updated_at
      }
    }

    # sort the items so that the categories are created in the order of newest first
    return_items.sort! { |x,y| y["updated_at"] <=> x["updated_at"]}

    # structure the data by category. If no category, use the from_user_tag
    return_items = return_items.group_by { |i| i["category_name"] || i["from_user_tag"]}

    # Sort items in each category by updated_at; newest items first, exculde unwanted attributes
    return_items.each do |key, value| 
      value = value.sort! { |a,b| 
        b["updated_at"] <=> a["updated_at"] 
      }
      value.each { |i| i.except! "category_name", "updated_at" }
    end

    # TODO: Return "from_user" as categories?
    { "type" => "items", "data" => return_items }
  end


  # -------------------------------------------------------------------------------------------
  # Class methods -----------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  

  def self.find_or_create_from_google_callback google_response
    # Check if a User exists
    user = User.find_by uid:google_response[:uid]
    return user unless user.nil?

    # Check if an unregistered user exists by the same email address
    # TODO: Make this case insensitive
    unregistered_user = UnregisteredUser.where(email: google_response[:info][:email]).first

    # Lets extract the parameters we're interested in
    user_params = {
      uid: google_response[:uid],
      name: google_response[:info][:name],
      email: google_response[:info][:email],
      first_name: google_response[:info][:first_name],
      last_name: google_response[:info][:last_name],
      image: google_response[:info][:image],
      token: google_response[:credentials][:token],
      refresh_token: google_response[:credentials][:refresh_token],
      expires_at: Time.at(google_response[:credentials][:expires_at].to_i).to_datetime
    }

    user = User.create! user_params
    return user if unregistered_user.nil?

    # Reassociate all items, friends, usage_data
    Item.where(user: unregistered_user).update_all("user_id = '#{user.id}', user_type = 'User'")
    Friend.where(receiving_user: unregistered_user).update_all("receiving_user_id = '#{user.id}', receiving_user_type = 'User'")
    UsageDatum.where(user: unregistered_user).update_all("user_id = '#{user.id}', user_type = 'User'")

    unregistered_user.destroy!
    return user
  end


  # -------------------------------------------------------------------------------------------
  # Helper methods ----------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  

  def refresh_tokens google_response
    new_attributes = google_response[:credentials].slice(:token, :refresh_token).select do |key,val|
      !val.nil? and !val.empty? and self[key] != val
    end
    self.update_attributes! new_attributes unless new_attributes.empty?
    logger.warn new_attributes.inspect
  end

  def generate_session_cookie
    self.sharey_session_cookie = ((0...20).map { (65 + rand(40)).chr }.join + "pam"*5).split("").shuffle.join
  end


  # -------------------------------------------------------------------------------------------
  # Unused/Untested methods -------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  

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
