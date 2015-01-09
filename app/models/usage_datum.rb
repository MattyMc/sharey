class UsageDatum < ActiveRecord::Base
  belongs_to :item

  validates :item_id, :viewed, :deleted, :click_count, :shared, presence: true
end
