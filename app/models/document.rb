class Document < ActiveRecord::Base
  
  # Relationships -----------------------------------------------------------------------------
  belongs_to :originator, class_name: "User"
  has_many   :items

  # Validations -------------------------------------------------------------------------------
  validates :url, :originator_id, presence: true
  validates :url, uniqueness: true


  # -------------------------------------------------------------------------------------------
  # Class methods -----------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  

  def self.first_or_initialize_with_url_title_and_originator url, title, user
    document = Document.where(url: url).first_or_initialize
    document.title = title if document.title.blank? and !title.blank?
    document.originator = user if document.new_record?
    document.save! 
    document
  end


end
