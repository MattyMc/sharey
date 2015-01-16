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

  # -------------------------------------------------------------------------------------------
  # Attributes --------------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------
  test "should have attribute messages" do
    item = Item.new
    assert_equal [], item.messages
    assert_equal Array, item.messages.class
  end

  # -------------------------------------------------------------------------------------------
  # validate_item_params ----------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------
  test "should return an array of elements" do
    item_params = {
      "url" => "http://www.somethingspecial.com/hamburger",
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    
    assert_equal([
      "http://www.somethingspecial.com/hamburger",
      "Hamburgers!",
      "Delicious treats!",
      "Food"], 
      Item.send(:validate_item_params, item_params))
  end

  test "should trim white space from all elements" do
    item_params = {
      "url" => "  http://www.somethingspecial.com/hamburger ",
      "title" => " Hamburgers!   ", 
      "description" => "    Delicious treats! ",
      "category" => " Food    "
    }
    
    assert_equal([
      "http://www.somethingspecial.com/hamburger",
      "Hamburgers!",
      "Delicious treats!",
      "Food"], 
      Item.send(:validate_item_params, item_params))
  end

  test "should raise an exception if url or description is an empty string" do
    item_params = {
      "url" => "  http://www.somethingspecial.com/hamburger ",
      "title" => " Hamburgers!   ", 
      "description" => "",
      "category" => " Food    "
    }
    assert_raises(Item::InvalidItemParams){Item.send(:validate_item_params, item_params)}

    item_params = {
      "url" => "   ",
      "title" => " Hamburgers!   ", 
      "description" => "something",
      "category" => " Food    "
    }
    assert_raises(Item::InvalidItemParams){Item.send(:validate_item_params, item_params)}
  end

  test "should raise an exception if url or description is nil" do
    item_params = {
      "url" => "  http://www.somethingspecial.com/hamburger ",
      "title" => " Hamburgers!   ", 
      "description" => nil,
      "category" => " Food    "
    }
    assert_raises(Item::InvalidItemParams){Item.send(:validate_item_params, item_params)}

    item_params = {
      "url" => nil,
      "title" => " Hamburgers!   ", 
      "description" => "something",
      "category" => " Food    "
    }
    assert_raises(Item::InvalidItemParams){Item.send(:validate_item_params, item_params)}
  end

  # -------------------------------------------------------------------------------------------
  # create_or_update_from_item_params_and_user ------------------------------------------------
  # -------------------------------------------------------------------------------------------
  # test "should not create a new item for an existing Document with a new User" do
  #   item_params = {
  #     "url" => documents(:some_video),
  #     "title" => "Hamburgers!", 
  #     "description" => "Delicious treats!",
  #     "category" => "Food"
  #   }
    
  #   user = users(:matt)
  #   assert_raises(Item::UserNotFound) {Item.create_or_update_from_item_params_and_user item_params, user}
  # end

  test "should create a new item for an existing Document with a new User" do
    doc_count = Document.count
    item_count = Item.count

    item_params = {
      "url" => documents(:some_video).url, # belongs to :matt
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    
    user = users(:pam)
    item = Item.create_or_update_from_item_params_and_user item_params, user
    category = Category.find_by(downcase_name: "food")

    assert category, "category should exist"
    assert_equal item_count+1, Item.count
    assert_equal doc_count, Document.count, "should not create a new document"
    assert_equal(
      [users(:pam), "Delicious treats!", documents(:some_video), "Delicious treats!"],
      [item.user, item.description, item.document, item.original_request])
    assert_equal category, item.category, "item should have category"
  end

  test "should not create a UsageDatum object with an existing item" do
    item_count = Item.count
    usage_datum_count = UsageDatum.count

    item_params = {
      "url" => documents(:some_video).url, # belongs to :matt
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    
    user = users(:matt)
    item = Item.create_or_update_from_item_params_and_user item_params, user

    assert_equal item_count, Item.count
    assert_equal usage_datum_count, UsageDatum.count
  end

  test "should create a UsageDatum object with a new item" do
    item_count = Item.count
    usage_datum_count = UsageDatum.count

    item_params = {
      "url" => "http://somethinghere.ca", # belongs to :matt
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    
    user = users(:matt)
    item = Item.create_or_update_from_item_params_and_user item_params, user

    assert_equal item_count+1, Item.count
    assert_equal usage_datum_count+1, UsageDatum.count
  end

  test "should create a new item and a new document" do
    doc_count = Document.count
    item_count = Item.count

    item_params = {
      "url" => "http://www.aintneverseenthisurl.com/", 
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    
    user = users(:matt)
    item = Item.create_or_update_from_item_params_and_user item_params, user
    last_doc = Document.last

    assert Category.find_by(downcase_name: "food"), "category should exist"    
    assert_equal item_count+1, Item.count
    assert_equal doc_count+1, Document.count
    assert_equal(
      [users(:matt), "Delicious treats!", last_doc, "Delicious treats!"],
      [item.user, item.description, item.document, item.original_request])
    
    assert_equal(
      ["http://www.aintneverseenthisurl.com/", users(:matt), "Hamburgers!"],
      [last_doc.url, last_doc.originator, last_doc.title])
  end

  test "should create a new category, item and document" do
    doc_count = Document.count
    item_count = Item.count
    cat_count = Category.count

    item_params = {
      "url" => "http://www.aintneverseenthisurl.com/", 
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    
    user = users(:matt)
    item = Item.create_or_update_from_item_params_and_user item_params, user
    last_doc = Document.last
    category = Category.find_by(downcase_name: "food")

    assert category, "category should exist"
    assert_equal item_count+1, Item.count
    assert_equal doc_count+1, Document.count
    assert_equal cat_count+1, Category.count
    assert_equal(
      ["Food", "food", users(:matt)],
      [category.name, category.downcase_name, category.user])
    assert_equal category, item.category
  end


  test "should update the description and category of an item if it exists" do
    doc_count = Document.count
    item_count = Item.count
    cat_count = Category.count

    item_params = {
      "url" => documents(:some_video).url, # belogs to matt
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    
    user = users(:matt)
    item = Item.create_or_update_from_item_params_and_user item_params, user

    assert_equal item_count, Item.count, "should not be creating a new item"
    assert_equal doc_count, Document.count
    assert_equal cat_count+1, Category.count
    assert_equal(
      [users(:matt).id, "Delicious treats!", documents(:some_video)],
      [item.user.id, item.description, item.document])
    
    assert_equal Category.find_by(downcase_name: "food"), item.category
  end

  test "should not update from_user of an item if it exists" do
    item_params = {
      "url" => documents(:insightful_story).url, # belogs to matt, from Pam
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    
    user = users(:matt)
    item = Item.create_or_update_from_item_params_and_user item_params, user

    assert_equal users(:pam), item.from_user
  end
    
  test "should update original_request of an item if it exists" do
    item_params = {
      "url" => documents(:insightful_story).url, # belogs to matt, from Pam
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    
    user = users(:matt)
    item = Item.create_or_update_from_item_params_and_user item_params, user

    assert_equal "Delicious treats!", item.original_request
  end

  test "should raise an exception if no user is defined" do
    item_params = {
      "url" => "http://www.somethingspecial.com/hamburger",
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    
    user = User.find_by sharey_session_cookie:"fakecookie"
    assert_raises(Item::UserNotFound) {Item.create_or_update_from_item_params_and_user item_params, user}
  end

  test "should create a document for a new url" do
    item_params = {
      "url" => "http://www.somethingspecial.com/hamburger",
      "title" => "Hamburgers!", 
      "description" => "Delicious treats!",
      "category" => "Food"
    }
    Item.create_or_update_from_item_params_and_user item_params, users(:pam)
    document = Document.find_by url:"http://www.somethingspecial.com/hamburger"

    assert document, "should find the new document"
    assert_equal(
      ["http://www.somethingspecial.com/hamburger","Hamburgers!",users(:pam)],
      [document.url, document.title, document.originator])
  end

  # -------------------------------------------------------------------------------------------
  # create_usage_datum ------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------
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
