require 'test_helper'
# TODO: Update diagram on README to include the association between users and this class
class UsageDatumTest < ActiveSupport::TestCase
  should belong_to :item
  should belong_to :user

  should validate_presence_of :item_id
  should validate_presence_of :user_id
  should validate_presence_of :user_type
  should_not allow_value(nil).for(:viewed)
  should_not allow_value(nil).for(:deleted)
  should_not allow_value(nil).for(:shared)
  should_not allow_value(nil).for(:user_id)
  should validate_presence_of :click_count

  test "should create a UsageDatum with default attributes" do
    usage_data = UsageDatum.new item:items(:matts_item), user:users(:matt)

    assert usage_data.save!, "should save UsageDatum: #{usage_data.inspect}"
    assert_equal items(:matts_item).id, usage_data.item.id
    assert_equal true, usage_data.viewed?
    assert_equal false, usage_data.deleted?
    assert_equal 0, usage_data.click_count
    assert_equal false, usage_data.shared?
    assert_equal users(:matt).id, usage_data.user_id
  end

  test "should create a usage_data with default attributes for an unregistered_user" do
    usage_data = UsageDatum.new item:items(:matts_item), user:unregistered_users(:pat)
  end
end
