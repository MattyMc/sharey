require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should have_many :items
  should have_many :categories
  should have_many :usage_data

  should have_many(:shared_items).class_name('Item').with_foreign_key('originator_id') 

  should validate_presence_of :uid
  should validate_presence_of :name
  should validate_presence_of :first_name
  should validate_presence_of :last_name
  should validate_presence_of :email
  should validate_presence_of :image
  should validate_presence_of :token
  should validate_presence_of :expires_at
  should validate_uniqueness_of :uid
  should validate_uniqueness_of :email

  # -------------------------------------------------------------------------------------------
  # last_n_items n  ---------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------
  # { categories: 
  #   { 
  #     category_name: "videos",
  #     items: 
  #       [ 
  #       {description: "", url: "", viewed: boolean, from_user_tag: "", destroy_url: "" },       
  #       {description: "", url: "", viewed: boolean, from_user_tag: "", destroy_url: "" },       
  #       {description: "", url: "", viewed: boolean, from_user_tag: "", destroy_url: "" }      
  #       ]
  #   },
  #   { 
  #     category_name: "articles",
  #     items: 
  #       [ 
  #       {description: "", url: "", viewed: boolean, from_user_tag: "", destroy_url: "" },       
  #       {description: "", url: "", viewed: boolean, from_user_tag: "", destroy_url: "" }      
  #       ]
  #   }
  # }
  test "should have last_n_items defined" do 
    assert users(:mau).respond_to?(:last_n_items), "should respond to method call"
  end

  test "should raise an exception and return a flash error if the user has no items saved" do
    user = users(:mau)
    assert_raises(CustomErrors::NoItemsFound) { user.last_n_items 10 }
  end

  test "should return one object with for a user who has one object saved" do
    user = users(:pam)

    count = 0 
    results = user.last_n_items(10)
    results.keys.each { |key| count += results[key].count}

    assert_equal 1, count
  end

  test "should return five objects with for a user who has two objects saved" do
    user = users(:matt)

    count = 0 
    results = user.last_n_items(10)
    results.keys.each { |key| count += results[key].count}

    assert_equal 5, count, results.inspect
  end

  test "should return exactly 2 items" do
    user = users(:matt)

    count = 0 
    results = user.last_n_items(2)
    results.keys.each { |key| count += results[key].count}

    assert_equal 2, count
  end

  test "should return exactly 4 items" do
    user = users(:matt)

    count = 0 
    results = user.last_n_items(4)
    results.keys.each { |key| count += results[key].count}

    assert_equal 4, count
  end

  test "should return exactly 5 items if n is equal to the number of items" do
    user = users(:matt)

    count = 0 
    results = user.last_n_items(5)
    results.keys.each { |key| count += results[key].count}

    assert_equal 5, count, results.inspect
  end

  test "should return exactly 5 items if n is greater than the number of items the user has" do
    # Assuming that exactly 5 items are create in items.yml
    user = users(:matt)

    count = 0 
    results = user.last_n_items(10)
    results.keys.each { |key| count += results[key].count}

    assert_equal 5, count
  end

  test "should return shared items first" do
    user = users(:matt)
    is = user.last_n_items(10)

    assert_equal nil, is.keys[0]
  end

  test "should order items from newest to oldest by updated_at" do
    user = users(:matt)
    is = user.last_n_items 10

    # Newest items first in 'videos' category
    assert_equal items(:matts_item_1).description, is["Videos"][0]["description"]
    assert_equal items(:matts_item).description, is["Videos"][1]["description"]

    # Newest items first in 'nil'["category"]
    assert_equal items(:to_matt_from_jay).description, is[nil][0]["description"]
    assert_equal items(:matts_item_2).description, is[nil][1]["description"]
    assert_equal items(:to_matt_from_pam).description, is[nil][2]["description"]
  end

  test "should include all defined categories" do
    user = users(:matt)
    is = user.last_n_items 10

    assert_equal [nil, "Videos"], is.keys
  end

  test "should return a properly structured object" do
    user = users(:matt)
    items = user.last_n_items 5

    assert_equal Hash, items.class
    assert_equal [nil, "Videos"], items.keys
    assert_equal Array, items[nil].class
    assert_equal Array, items["Videos"].class
    assert_equal 2, items["Videos"].count
    assert_equal 3, items[nil].count
  end

  test "should contain description attribute in each return object" do
    user = users(:matt)
    items = user.last_n_items 5

    items[nil].each do |item|
      assert_equal Hash, item.class
      refute item["description"].empty?
      assert String, item["description"].class
    end
    
    items["Videos"].each do |item|
      assert_equal Hash, item.class
      refute item["description"].empty?
      assert String, item["description"].class
    end
  end

  test "should contain url attribute in each return object" do
    user = users(:matt)
    items = user.last_n_items 5

    items[nil].each do |item|
      assert_equal Hash, item.class
      refute item["url"].empty?
      assert_equal String, item["url"].class
    end

    items["Videos"].each do |item|
      assert_equal Hash, item.class
      refute item["url"].empty?
      assert_equal String, item["url"].class
    end
  end

  test "should contain viewed attribute in each return object" do
    user = users(:matt)
    items = user.last_n_items 5

    items[nil].each do |item|
      refute item["viewed"].nil?
    end

    items["Videos"].each do |item|
      refute item["viewed"].nil?
    end
  end

  test "should contain destroy_url attribute in each return object" do
    user = users(:matt)
    items = user.last_n_items 5

    items[nil].each do |item|
      refute item["destroy_url"].nil?
      assert_equal String, item["destroy_url"].class
    end

    items["Videos"].each do |item|
      refute item["destroy_url"].nil?
      assert_equal String, item["destroy_url"].class
    end
  end

  test "should not contain attributes in each item other than description, url, viewed, from_user_tag, destroy_url" do
    user = users(:matt)
    items = user.last_n_items 5

    items[nil].each do |item|
      assert_equal Hash, item.class
      assert_equal ["description", "url", "viewed", "from_user_tag", "destroy_url"].sort, item.keys.sort
    end  

    items["Videos"].each do |item|
      assert_equal Hash, item.class
      assert_equal ["description", "url", "viewed", "from_user_tag", "destroy_url"].sort, item.keys.sort
    end  
  end

  test "should properly set attribute viewed" do
    user = users(:matt)
    is = user.last_n_items 10

    is[nil].each do |item|
      assert_equal Item.find_by(description: item["description"], user:user).usage_datum.viewed, item["viewed"]
    end

    is["Videos"].each do |item|
      assert_equal Item.find_by(description: item["description"], user:user).usage_datum.viewed, item["viewed"]
    end
  end

  test "should properly set attribute destroy_url" do
    user = users(:matt)
    is = user.last_n_items 10

    is[nil].each do |item|
      attr_test = "items/" + Item.find_by(description: item["description"], user:user).id.to_s
      assert_equal attr_test, item["destroy_url"]
    end

    is["Videos"].each do |item|
      attr_test = "items/" + Item.find_by(description: item["description"], user:user).id.to_s
      assert_equal attr_test, item["destroy_url"]
    end
  end

  test "should properly set attribute from_user_tag" do
    user = users(:matt)
    is = user.last_n_items 10

    assert_equal "@Jay", is[nil][0]["from_user_tag"]
    assert_equal nil, is[nil][1]["from_user_tag"]
    assert_equal "@pam", is[nil][2]["from_user_tag"]
    
    assert_equal nil, is["Videos"][0]["from_user_tag"]
    assert_equal nil, is["Videos"][1]["from_user_tag"]
  end

  # -------------------------------------------------------------------------------------------
  # get_number_of_unviewed_items  ---------------------------------------------------------------
  # -------------------------------------------------------------------------------------------
  test "should return 0 if the user has no unread items" do
    user = users(:mau)
    assert_equal 0, user.get_number_of_unviewed_items
  end

  test "should return 1 if the user has one unread items" do
    user = users(:mau)
    assert_equal 0, user.get_number_of_unviewed_items

    item_params = {
      "url" => "www.blah.com", 
      "title" => "Hamburgers!", 
      "description" => "@mau Delicious treats!",
      "category" => "Food"
    }
    Item.create_or_update_from_item_params_and_user item_params, users(:matt)
    
    assert_equal 1, user.get_number_of_unviewed_items
  end

  test "should return 2 if the user has two unread items" do
    user = users(:mau)
    assert_equal 0, user.get_number_of_unviewed_items

    item_params = {
      "url" => "www.blah.com", 
      "title" => "Hamburgers!", 
      "description" => "@mau Delicious treats!",
      "category" => "Food"
    }
    Item.create_or_update_from_item_params_and_user item_params, users(:matt)
    
    item_params = {
      "url" => "www.blahhhhhhh.com", 
      "title" => "Hamburgers!", 
      "description" => "@mau Delicious treats!",
      "category" => "Food"
    }
    Item.create_or_update_from_item_params_and_user item_params, users(:matt)
  
    assert_equal 2, user.reload.get_number_of_unviewed_items
  end

  test "should return 2 if the user has two unread items and should not count a bad request" do
    user = users(:mau)
    assert_equal 0, user.get_number_of_unviewed_items

    item_params = {
      "url" => "www.blah.com", 
      "title" => "Hamburgers!", 
      "description" => "@mau Delicious treats!",
      "category" => "Food"
    }
    Item.create_or_update_from_item_params_and_user item_params, users(:matt)
    
    item_params = {
      "url" => "www.blahhhhhhh.com", 
      "title" => "Hamburgers!", 
      "description" => "@mau Delicious treats!",
      "category" => "Food"
    }
    Item.create_or_update_from_item_params_and_user item_params, users(:matt)
    
    # This one shouldn't count, as it's the same as item#1 above
    item_params = {
      "url" => "www.blah.com", 
      "title" => "Hamburgers!", 
      "description" => "@mau Delicious treats!",
      "category" => "Food"
    }
    Item.create_or_update_from_item_params_and_user item_params, users(:matt)
  
    assert_equal 2, user.reload.get_number_of_unviewed_items
  end


  # Make sure the User class responds_to our new method
  test "User should respond to find_or_create_from_google_callback method" do
    assert User.respond_to?( :find_or_create_from_google_callback), "User.create_from_google_callback should exist" 
  end

  # We'll be looking up users by their uid's. Lets make sure our app
  # behaves appropriately here. Making use of the response Hash:
  test "should create a new user from Google's callback params" do
    google_response = {
        :provider => "google_oauth2",
        :uid => "123456789",
        :info => {
            :name => "John Doe",
            :email => "john@company_name.com",
            :first_name => "John",
            :last_name => "Doe",
            :image => "https://lh3.googleusercontent.com/url/photo.jpg"
        },
        :credentials => {
            :token => "token",
            :refresh_token => "another_token",
            :expires_at => 1354920555,
            :expires => true
        },
        :extra => {
            :raw_info => {
                :sub => "123456789",
                :email => "user@domain.example.com",
                :email_verified => true,
                :name => "John Doe",
                :given_name => "John",
                :family_name => "Doe",
                :profile => "https://plus.google.com/123456789",
                :picture => "https://lh3.googleusercontent.com/url/photo.jpg",
                :gender => "male",
                :birthday => "0000-06-25",
                :locale => "en",
                :hd => "company_name.com"
            }
        }
    }
    user_count = User.count

    user = User.find_or_create_from_google_callback google_response
    # Have we created a new record?
    assert_equal (user_count+1), User.count
    assert_equal User, user.class
    assert_equal User.find_by(uid: "123456789"), user
  end  

  test "should find and return an existing user from Google's callback params" do
    google_response = {
        :provider => "google_oauth2",
        :uid => "123456789",
        :info => {
            :name => "John Doe",
            :email => "john@company_name.com",
            :first_name => "John",
            :last_name => "Doe",
            :image => "https://lh3.googleusercontent.com/url/photo.jpg"
        },
        :credentials => {
            :token => "token",
            :refresh_token => "another_token",
            :expires_at => 1354920555,
            :expires => true
        },
        :extra => {
            :raw_info => {
                :sub => "123456789",
                :email => "user@domain.example.com",
                :email_verified => true,
                :name => "John Doe",
                :given_name => "John",
                :family_name => "Doe",
                :profile => "https://plus.google.com/123456789",
                :picture => "https://lh3.googleusercontent.com/url/photo.jpg",
                :gender => "male",
                :birthday => "0000-06-25",
                :locale => "en",
                :hd => "company_name.com"
            }
        }
    }
    User.find_or_create_from_google_callback google_response
    user_count = User.count

    user = User.find_or_create_from_google_callback google_response
    # Have we created a new record?
    refute_nil user
    assert_equal user_count, User.count
    assert_equal User, user.class
  end

  test "should not update token if empty" do
    pam = users(:pam)
    google_response = pam.to_request

    pam[:token] = "sometoken"
    pam.save
    # Change the token to empty
    google_response[:credentials][:token] = ""
    pam.refresh_tokens google_response
    assert_equal "sometoken", pam.reload.token
  end

  test "should not update token if nil" do
    pam = users(:pam)
    google_response = pam.to_request

    pam[:token] = "sometoken"
    pam.save
    # Change the token to empty
    google_response[:credentials][:token] = nil
    pam.refresh_tokens google_response
    assert_equal "sometoken", pam.reload.token
  end

  test "should not update refresh_token if empty" do
    pam = users(:pam)
    google_response = pam.to_request

    pam[:refresh_token] = "some_refresh_token"
    pam.save
    # Change the refresh_token to empty
    google_response[:credentials][:refresh_token] = ""
    pam.refresh_tokens google_response
    assert_equal "some_refresh_token", pam.reload.refresh_token
  end

  test "should not update refresh_token if nil" do
    pam = users(:pam)
    google_response = pam.to_request

    pam[:refresh_token] = "some_refresh_token"
    pam.save
    # Change the refresh_token to empty
    google_response[:credentials]["refresh_token"] = nil
    pam.refresh_tokens google_response
    assert_equal "some_refresh_token", pam.reload.refresh_token
  end

  test "should change sharey_session_cookie upon refreshing tokens" do
    pam = users(:pam)
    google_response = pam.to_request

    pam[:sharey_session_cookie] = "some_cookie"
    pam.save
    pam.refresh_tokens google_response
    refute_equal "some_cookie", pam.reload.sharey_session_cookie
  end

  test "should update token and refresh token if response is different from stored values" do
    pam = users(:pam)
    google_response = pam.to_request

    # Change the tokens
    google_response[:credentials][:token] = "newtoken"
    pam.refresh_tokens google_response

    assert_equal "newtoken", pam.reload.token

    google_response[:credentials][:refresh_token] = "newrefreshtoken"
    pam.refresh_tokens google_response

    assert_equal "newrefreshtoken", pam.reload.refresh_token
  end

  test "should respond to .refresh_tokens method" do 
    assert User.new.respond_to?(:refresh_tokens), "cannot find method :refresh_tokens"
  end


end
