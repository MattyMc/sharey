require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should have_many :items
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
