require 'test_helper'

class ItemsControllerTest < ActionController::TestCase


  # -------------------------------------------------------------------------------------------
  # post :create_or_update --------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------
  # General form of post helper: post(action_name, params_hash = {}, session_hash = {})



  # --------------- these tests are mostly covered in unit tests now --------------------------
  test "should raise an exception if user cannot be found by their sharey_session_cookie" do
    cookies[:sharey_session_cookie] = users(:pam).sharey_session_cookie + "thjakgdha"
    assert_raises(ItemsController::UserNotFound) {
      post :create_or_update, {
      item: {
        url: "http://www.something.com",
        category: "some category",
        description: "here's something I'd like to save",
        title: "some website title"
        }
      }
    }
  end

  test "should create an Item, Document, Category and UsageData" do
    item_count = Item.count
    document_count = Document.count
    category_count = Category.count
    usage_datum_count = UsageDatum.count
    pams_item_count = users(:pam).items.count

    cookies[:sharey_session_cookie] = users(:pam).sharey_session_cookie
    post :create_or_update, {
      item: {
        url: "http://www.something.com",
        category: "some category I'm creating",
        description: "here's something I'd like to save",
        title: "some website title"
        }
      }

    assert_equal item_count+1, Item.count
    assert_equal document_count+1, Document.count
    assert_equal category_count+1, Category.count
    assert_equal usage_datum_count+1, UsageDatum.count
    assert_equal pams_item_count+1, users(:pam).items.count
  end

  test "should not create a new document for an existing URL" do
    item_count = Item.count
    document_count = Document.count
    category_count = Category.count
    usage_datum_count = UsageDatum.count
    pams_item_count = users(:pam).items.count

    cookies[:sharey_session_cookie] = users(:pam).sharey_session_cookie
    post :create_or_update, {
      item: {
        url: documents(:some_video).url, # owned by matt
        category: "some category I'm creating",
        description: "here's something I'd like to save",
        title: "some website title"
        }
      }

    assert_equal documents(:some_video).url, Document.last.url
    assert_equal item_count+1, Item.count
    assert_equal document_count, Document.count
    assert_equal category_count+1, Category.count
    assert_equal usage_datum_count+1, UsageDatum.count
  end


  test "should not create a new item if a user already has saved that item" do
    item_count = Item.count
    document_count = Document.count
    category_count = Category.count
    usage_datum_count = UsageDatum.count

    cookies[:sharey_session_cookie] = users(:matt).sharey_session_cookie
    post :create_or_update, {
      item: {
        url: documents(:some_video).url,
        category: "some category I'm creating",
        description: "here's something I'd like to save",
        title: "some website title"
        }
      }

    assert_equal item_count, Item.count
    assert_equal document_count, Document.count
    assert_equal usage_datum_count, UsageDatum.count
  end

  test "should update an item if a user already has saved that item" do
    item_count = Item.count
    document_count = Document.count
    category_count = Category.count
    usage_datum_count = UsageDatum.count

    cookies[:sharey_session_cookie] = users(:matt).sharey_session_cookie
    post :create_or_update, {
      item: {
        url: documents(:some_video).url,
        category: "new category",
        description: "new description",
        title: "some website title"
        }
      }

    new_item = Item.find_by(document: Document.find_by(url: documents(:some_video).url))
    assert_equal "www.youtube.com/watch?v=K2ZBubuxqVA", documents(:some_video).url
    assert_equal item_count, Item.count
    assert_equal document_count, Document.count
    assert_equal category_count+1, Category.count, "should create a new category"
    assert_equal usage_datum_count, UsageDatum.count
    assert_equal "new description", new_item.description
    assert Category.find_by(name: "new category")
    assert_equal users(:matt), Category.find_by(name: "new category").user
  end

  test "should not create a new category even if there are leading spaces" do
    category_count = Category.count

    cookies[:sharey_session_cookie] = users(:matt).sharey_session_cookie
    post :create_or_update, {
      item: {
        url: "http://www.something.com",
        category: " videos",
        description: "new description",
        title: "some website title"
        }
      }

    assert_equal category_count, Category.count, "should not create a new category"
  end  

  test "should not create a new category even if there are trailing spaces" do
    category_count = Category.count

    cookies[:sharey_session_cookie] = users(:matt).sharey_session_cookie
    post :create_or_update, {
      item: {
        url: "http://www.something.com",
        category: "videos ",
        description: "new description",
        title: "some website title"
        }
      }

    assert_equal category_count, Category.count, "should not create a new category"
  end

  test "should find a category for capital letters" do
    category_count = Category.count

    cookies[:sharey_session_cookie] = users(:matt).sharey_session_cookie
    post :create_or_update, {
      item: {
        url: "http://www.something.com",
        category: " VIDeos",
        description: "new description",
        title: "some website title"
        }
      }

    assert_equal category_count, Category.count, "should not create a new category"
  end


end
