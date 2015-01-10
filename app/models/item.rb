class Item < ActiveRecord::Base
  belongs_to :user
  belongs_to :document
  belongs_to :category
  has_one :usage_datum
  belongs_to :from_user, class_name: "User", foreign_key: "from_user_id"

  validates :document_id, :user_id, :description, :original_request, presence: true

  # Item will automatically create and manage its data
  after_create :create_usage_datum

  private 

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
