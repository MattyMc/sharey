class UsageDatum < ActiveRecord::Base
  
  # Relationships -----------------------------------------------------------------------------
  belongs_to :item
  belongs_to :user, polymorphic: true

  # Validations -------------------------------------------------------------------------------
  validates :item_id,  :click_count, :user_id, :user_type, presence: true
  validates :viewed, :deleted, :shared, inclusion: [true, false]

  # TODO: Consider adding a unique constraint to item_id
end
