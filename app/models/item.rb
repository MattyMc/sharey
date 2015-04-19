require 'item_messages'
require 'custom_errors'

class Item < ActiveRecord::Base
  # Modules ----------------------------------------------------------------------------------- 
  include ItemMessages 
  include CustomErrors
  
  # Attributes -------------------------------------------------------------------------------- 
  attr_accessor :notes

  # Relationships -----------------------------------------------------------------------------
  belongs_to :user
  belongs_to :document
  belongs_to :category
  belongs_to :from_user, class_name: "User", foreign_key: "from_user_id"
  has_one    :usage_datum
  
  # Validations -------------------------------------------------------------------------------
  validates :document_id, :user_id, :description, :original_request, presence: true
  validates :user_id, uniqueness: { scope: :document_id }

  # Filters -----------------------------------------------------------------------------------
  after_create :create_usage_datum  # Item will automatically create and manage its data
  after_initialize :set_defaults

  def set_defaults 
    # These are used by the module ItemMessages
    self.notes = {
      "tagged_users" => [], 
      "missing_tags" => [], 
      "already_saved" => [],
      "already_shared_with" => [], 
      "new_item" => false}
  end

  # Errors ------------------------------------------------------------------------------------
  # ------- now located in custom_errors module -----------------------------------------------
  


  # -------------------------------------------------------------------------------------------
  # Instance methods --------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  

  def clicked
    usage_datum = self.usage_datum
    usage_datum.viewed = true
    usage_datum.click_count += 1

    usage_datum.save!
  end


  # -------------------------------------------------------------------------------------------
  # Class methods -----------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  

  def self.create_or_update_from_item_params_and_user item_params, user
    raise UserNotFound if user.nil?
    url, title, original_request, cat_name = validate_item_params item_params

    description, tag_array = Friend.parse_tag_array original_request
    share_with_users, missing_tags = Friend.find_valid_friends_for_user user, tag_array unless tag_array.empty?
    # mising_tags will return an array of the tags that are not defined for that user (ie not friends)
    # share_with_users is a hash: {"@matt" => matt_id, "@jay" => jay_id, ...}

    # Logic: 
    # If the Document is a new record, Item is for sure new
    # If Document is not new, then:
    # The Item could still be new for this particular User
    # The Item could exist for this user. In this case, update the Category and Description
    # TODO: rename the methods below to first_or_create_with... ?
    document = Document.first_or_initialize_with_url_title_and_originator(url, title, user)
    category = Category.first_or_initialize_with_name_and_user cat_name, user

    item = Item.includes("usage_datum").where(
      document: document,
      user: user).first_or_initialize

    item.notes["new_item"]  = true if item.new_record?
    item.notes["missing_tags"] = missing_tags unless missing_tags.nil?

    # TODO: Make sure User and Document are unique
    # TODO: Don't allow other users to overwrite a description that already exists
    # TODO: Set a default value of null for from_user_id
    item.description = description
    item.original_request = original_request
    item.category = category unless category.nil?
    item.from_user = nil if item.new_record?

    # Is a deleted item being re-saved?
    item.usage_datum.update(deleted: false) if !item.new_record? and item.usage_datum.deleted
    
    item.save!

    # Share with tagged users
    # TODO: Do this hitting the db less
    if !share_with_users.nil? and !share_with_users.empty?
      
      share_with_users.each do |tag, receiving_user|
        shared_item = Item.where(document:document, user:receiving_user).first_or_initialize
        if shared_item.new_record?
          shared_item.from_user = user
          shared_item.description = description
          shared_item.original_request = original_request
          item.notes["tagged_users"] << tag if shared_item.save!
        else
          shared_item.from_user_id == user.id ? item.notes["already_shared_with"] << tag : item.notes["already_saved"] << tag
        end
      end

    end

    return item
  end


  private 


  # -------------------------------------------------------------------------------------------
  # Helper methods ----------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  

  def self.validate_item_params item_params
    # Validations:
    # User must be defined (ie must have a valid sharey_session_cookie)
    # url and description attributes must be defined
    raise InvalidItemParams if item_params["url"].nil? or item_params["description"].nil?
    raise InvalidItemParams unless item_params["url"].present? and item_params["description"].present?

    item_params.values.map(&:strip!)
    [item_params["url"], item_params["title"], item_params["description"], item_params["category"]]
  end

  def create_usage_datum
    usage_datum = UsageDatum.where(item: self, user: self.user).first_or_initialize
    # If item is being created for a different user, set the below default values
    if self.from_user_id
      usage_datum.viewed = false 
      usage_datum.shared = true 
    end
    usage_datum.save!
  end

end
