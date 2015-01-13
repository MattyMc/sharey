class UsageDatum < ActiveRecord::Base
  
  # Relationships -----------------------------------------------------------------------------
  belongs_to :item

  # Validations -------------------------------------------------------------------------------
  validates :item_id,  :click_count, presence: true
  validates :viewed, :deleted, :shared, inclusion: [true, false]

  # TODO: Consider adding a unique constraint to item_id
end
