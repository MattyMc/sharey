require 'test_helper'

class ItemsControllerTest < ActionController::TestCase
  # Easily test response parameters using json_response['result']
  def json_response
    ActiveSupport::JSON.decode @response.body
  end

  # -------------------------------------------------------------------------------------------
  # post :create_or_update --------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------
  # General form of post helper: post(action_name, params_hash = {}, session_hash = {})

  test "should respond with a properly formatted JSON reply on failure" do
    post :create_or_update, {}
    assert_response :bad_request 

    # Make sure deprecated responses are gone
    refute json_response["result"]  
    refute json_response["headline"]  
    refute json_response["messages"]  

    # Test response object
    assert json_response["modal"]["headline"]  
    assert json_response["modal"]["messages"]  
    assert_equal Array, json_response["modal"]["messages"].class
    assert_equal "Who are you, again?", json_response["modal"]["messages"][0]
  end

  test "should respond with a properly formatted JSON reply on success" do
    cookies[:sharey_session_cookie] = users(:pam).sharey_session_cookie
    post :create_or_update, {
    item: {
      url: "http://www.something.com",
      category: "some category",
      description: "here's something I'd like to save",
      title: "some website title"
      }
    }
    assert_response :success 

    # Test response object
    assert json_response["modal"]["headline"]  
    assert json_response["modal"]["messages"]  
    assert_equal Array, json_response["modal"]["messages"].class
    assert_equal "Saved!", json_response["modal"]["headline"]
  end

  test "should respond with an error if url is not defined" do
    cookies[:sharey_session_cookie] = users(:pam).sharey_session_cookie
    
    post :create_or_update, {
    item: {
      url: "",
      category: "some category",
      description: "here's something I'd like to save",
      title: "some website title"
      }
    }
    # Test response object
    assert_response :bad_request
    assert json_response["modal"]["headline"]  
    assert json_response["modal"]["messages"]  
    assert_equal Array, json_response["modal"]["messages"].class
    assert_equal "Please enter a description!", json_response["modal"]["messages"][0]
  end

  test "should respond with an error if description is not defined" do
    cookies[:sharey_session_cookie] = users(:pam).sharey_session_cookie
    
    post :create_or_update, {
    item: {
      url: "http://www.something.com",
      category: "some category",
      description: "",
      title: "some website title"
      }
    }
    # Test response object
    assert_response :bad_request
    assert json_response["modal"]["headline"]  
    assert json_response["modal"]["messages"]  
    assert_equal Array, json_response["modal"]["messages"].class
    assert_equal "Please enter a description!", json_response["modal"]["messages"][0]
  end

  test "should respond with an error if neither the description or url is not defined" do
    cookies[:sharey_session_cookie] = users(:pam).sharey_session_cookie
    
    post :create_or_update, {
    item: {
      url: "",
      category: "some category",
      description: "",
      title: "some website title"
      }
    }
    # Test response object
    assert_response :bad_request
    assert json_response["modal"]["headline"]  
    assert json_response["modal"]["messages"]  
    assert_equal Array, json_response["modal"]["messages"].class
    assert_equal "Please enter a description!", json_response["modal"]["messages"][0]
  end

  # --------------- testing response values  -------------------------------------------------  
  # Three possibilities when saving an item: 
  # 1. error
  # 2. create a new item
  # 3. update an existing item
  # 
  # Three possibilities with sharing an item with one user:
  # 1. Successfully share items with user
  # 2. That user already has that item saved (ie do nothing, return message)
  # 3. Could not find that user (return message)
  # 
  # These possibilities and their interactions are test in item_test.rb
  # Here, I'm only testing (for now) that in each case we receive some sort of response
  # (NOTE: The error outcome is tested above)

  test "should respond with proper headline and messages when creating an item for one user" do
    cookies[:sharey_session_cookie] = users(:pam).sharey_session_cookie
    post :create_or_update, {
    item: {
      url: "http://www.something.com",
      category: "some category",
      description: "here's something I'd like to save",
      title: "some website title"
      }
    }
    assert_response :success 

    # Test response object
    refute json_response["modal"]["headline"].blank?, json_response["modal"]["headline"]
    refute json_response["modal"]["messages"].empty?, json_response["modal"]["messages"]
    assert_equal Array, json_response["modal"]["messages"].class
  end

  test "should respond with proper headline and messages when creating an item for one user with tags" do
    cookies[:sharey_session_cookie] = users(:pam).sharey_session_cookie
    post :create_or_update, {
    item: {
      url: "http://www.something.com",
      category: "some category",
      description: "here's something I'd like to save @matt @jay @mau",
      title: "some website title"
      }
    }
    assert_response :success 

    # Test response object
    refute json_response["modal"]["headline"].blank?
    refute json_response["modal"]["messages"].empty?
    assert_equal Array, json_response["modal"]["messages"].class
  end

  # TODO: Find a way to test that the responses are coming in properly, ie with a proper format
  test "should respond with proper headline and messages when updating an item for one user" do
    cookies[:sharey_session_cookie] = users(:pam).sharey_session_cookie
    post :create_or_update, {
    item: {
      url: documents(:insightful_story).url, # pam has this already saved
      category: "some category",
      description: "here's something I'd like to save",
      title: "some website title"
      }
    }
    assert_response :success 

    # Test response object
    refute json_response["modal"]["headline"].blank?
    refute json_response["modal"]["messages"].empty?
    assert_equal Array, json_response["modal"]["messages"].class
  end

  test "should respond with proper headline and messages when updating an item for one user with tags" do
    cookies[:sharey_session_cookie] = users(:pam).sharey_session_cookie
    post :create_or_update, {
    item: {
      url: documents(:insightful_story).url, # pam has this already saved
      category: "some category",
      description: "here's something I'd like to save @pam @jay @mau @shaggy",
      title: "some website title"
      }
    }
    assert_response :success 

    # Test response object
    refute json_response["modal"]["headline"].blank?
    refute json_response["modal"]["messages"].empty?
    assert_equal Array, json_response["modal"]["messages"].class
  end

  # --------------- these tests are  covered in unit tests now --------------------------------
  test "should raise an exception if user cannot be found by their sharey_session_cookie" do
    cookies[:sharey_session_cookie] = users(:pam).sharey_session_cookie + "thjakgdha"
    
    post :create_or_update, {
    item: {
      url: "http://www.something.com",
      category: "some category",
      description: "here's something I'd like to save",
      title: "some website title"
      }
    }
    
    assert_response :bad_request
  end

  test "should not raise an exception if user can be found by their sharey_session_cookie" do
    cookies[:sharey_session_cookie] = users(:pam).sharey_session_cookie
    
    post :create_or_update, {
    item: {
      url: "http://www.somethingunique.com",
      category: "some category",
      description: "here's something I'd like to save",
      title: "some website title"
      }
    }
    
    assert_response :success
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
