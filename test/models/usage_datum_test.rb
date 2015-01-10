require 'test_helper'

class UsageDatumTest < ActiveSupport::TestCase
  should belong_to :item

  should validate_presence_of :item_id
  should_not allow_value(nil).for(:viewed)
  should_not allow_value(nil).for(:deleted)
  should_not allow_value(nil).for(:shared)
  should validate_presence_of :click_count

  test "should create a UsageDatum with default attributes" do
    usage_data = UsageDatum.new item:items(:matts_item)

    assert usage_data.save!, "should save UsageDatum: #{usage_data.inspect}"
    assert_equal items(:matts_item).id, usage_data.item.id
    assert_equal true, usage_data.viewed?
    assert_equal false, usage_data.deleted?
    assert_equal 0, usage_data.click_count
    assert_equal false, usage_data.shared?
  end

end
