require 'test_helper'

class UsageDatumTest < ActiveSupport::TestCase
  should belong_to :item

  should validate_presence_of :item_id
  should validate_presence_of :viewed
  should validate_presence_of :deleted
  should validate_presence_of :click_count
  should validate_presence_of :shared
end
