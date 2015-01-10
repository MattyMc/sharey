class UsageDatum < ActiveRecord::Base
  belongs_to :item

  validates :item_id,  :click_count, presence: true
  validates :viewed, :deleted, :shared, inclusion: [true, false]
end
