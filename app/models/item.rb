class Item < ActiveRecord::Base
  # Attributes -------------------------------------------------------------------------------- 
  attr_accessor :messages

  # Relationships -----------------------------------------------------------------------------
  belongs_to :user
  belongs_to :document
  belongs_to :category
  belongs_to :from_user, class_name: "User", foreign_key: "from_user_id"
  has_one    :usage_datum
  
  # Validations -------------------------------------------------------------------------------
  validates :document_id, :user_id, :description, :original_request, presence: true

  # Filters -----------------------------------------------------------------------------------
  after_create :create_usage_datum  # Item will automatically create and manage its data
  after_initialize :set_defaults

  def set_defaults; self.messages = []; end

  # Errors ------------------------------------------------------------------------------------
  class UserNotFound < StandardError; end
  class InvalidItemParams < StandardError; end
  


  # -------------------------------------------------------------------------------------------
  # Class methods -----------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  

  def self.create_or_update_from_item_params_and_user item_params, user
    raise UserNotFound if user.nil?
    doc_url, doc_title, item_description, cat_name = validate_item_params item_params

    # Logic: 
    # If the Document is a new record, Item is for sure new
    # If Document is not new, then:
    # The Item could still be new for this particular User
    # The Item could exist for this user. In this case, update the Category and Description
    document = Document.first_or_initialize_with_url_title_and_originator(doc_url, doc_title, user)
    category = Category.first_or_initialize_with_name_and_user cat_name, user

    item = Item.where(
      document: document,
      user: user).first_or_initialize
    # TODO: Make sure User and Document are unique
    # TODO: Don't allow other users to overwrite a description that already exists
    # TODO: Set a default value of null for from_user_id
    item.description = item_description
    item.original_request = item_description
    item.category = category
    item.from_user = nil if item.new_record?

    item.save!
    item
  end


  private 


  # -------------------------------------------------------------------------------------------
  # Helper methods ----------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  

  def self.validate_item_params item_params
    # Validations:
    # User must be defined (ie must have a valid sharey_session_cookie)
    # url and description attributes must be defined
    raise InvalidItemParams, "Please enter a description!" if item_params["url"].nil? or item_params["description"].nil?
    raise InvalidItemParams, "Please enter a description!"  unless item_params["url"].present? and item_params["description"].present?

    item_params.values.map(&:strip!)
    [item_params["url"], item_params["title"], item_params["description"], item_params["category"]]
  end

  def create_usage_datum
    usage_datum = UsageDatum.where(item: self).first_or_initialize
    # If item is being created for a different user, set the below default values
    if self.from_user_id
      usage_datum.viewed = false 
      usage_datum.shared = true 
    end
    usage_datum.save!
  end

end
