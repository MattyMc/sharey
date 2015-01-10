require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  should belong_to :user
  should belong_to :document
  should belong_to :category
  should have_one :usage_datum
  should belong_to(:from_user).class_name('User').with_foreign_key('from_user_id')
  
  should validate_presence_of :document_id
  should validate_presence_of :user_id
  should validate_presence_of :description
  should validate_presence_of :original_request

  # test "should create a new item" do
  #   pam = users(:pam)
  #   item_count = Item.count

  #   category = Category.create! name:"New Cat"
  # end

  test "should create a UsageDatum model along with an item" do
    usage_datum_count = UsageDatum.count

    item = Item.new(document:documents(:some_video), 
      user:users(:pam), 
      from_user_id: nil,
      description: "Some description",
      category: nil,
      original_request: "Some description")

    assert item.save!, "should save item"
    assert_equal usage_datum_count+1, UsageDatum.count

    assert_equal false, item.usage_datum.shared?
    assert_equal true, item.usage_datum.viewed?
  end

  test "should set correctly set UsageDatum attributes if creating an item to be shared" do
    usage_datum_count = UsageDatum.count

    # This item is from Matt to Pam
    item = Item.new(document:documents(:some_video), 
      user:users(:pam), 
      from_user: users(:matt),
      description: "Some description",
      category: nil,
      original_request: "Some description")

    assert item.save!, "should save item"
    assert_equal usage_datum_count+1, UsageDatum.count

    assert_equal true, item.usage_datum.shared?
    assert_equal false, item.usage_datum.viewed?
  end

  test "should not create a new UsageDatum if item already exists" do
    # This item is from Matt to Pam
    item = Item.create!(document:documents(:some_video), 
      user:users(:pam), 
      from_user: users(:matt),
      description: "Some description",
      category: nil,
      original_request: "Some description")

    usage_datum_count = UsageDatum.count
    item_count = Item.count

    # This item is from Matt to Pam
    item = Item.new(document:documents(:some_video), 
      user:users(:pam), 
      from_user: users(:matt),
      description: "Some new description",
      category: nil,
      original_request: "Some new description")

    assert_equal item_count, Item.count
    assert_equal usage_datum_count, UsageDatum.count
  end

  test "should not create a new UsageDatum if updating record" do
    # This item is from Matt to Pam
    item = Item.create!(document:documents(:some_video), 
      user:users(:pam), 
      from_user: users(:matt),
      description: "Some description",
      category: nil,
      original_request: "Some description")

    usage_datum_count = UsageDatum.count

    item.update_attributes! description:"Some new description..."

    assert_equal "Some new description...", item.description
    assert_equal usage_datum_count, UsageDatum.count
  end
end
