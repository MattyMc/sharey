require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  test "should access helper" do
    assert User.new.respond_to?(:to_request), "should be able to access :to_request from UserTests module"
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should route root_path to sessions#index" do
    assert_routing({ path: '/', method: :get }, { controller: 'sessions', action: 'index' })
  end  

  test "should raise an exception if request.env['omniauth.auth'] is not defined" do
    assert_raises(RuntimeError) { get :create, provider: "google_oauth2" }
  end

  test "should create a new user on first login" do
    @request.env['omniauth.auth'] = {
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
    }.with_indifferent_access
    user_count = User.count

    get :create, provider: "google_oauth2"

    assert_equal user_count+1, User.count
    assert User.find_by_uid("123456789"), "should be able to retrieve the new user"
    assert_equal User.find_by_uid("123456789"), assigns["current_user"]
  end

  # Not included in default application
  test "should set cookies['sharey_session_cookie'] upon creating a new user" do

    @request.env['omniauth.auth'] = {
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
    }.with_indifferent_access


    get :create, provider: "google_oauth2"

    user = User.find_by_uid "123456789"
    refute_nil user.sharey_session_cookie
    assert user.sharey_session_cookie.length > 10
    assert_equal user.sharey_session_cookie, cookies[:sharey_session_cookie]
  end

  test "should redirect to root path after create" do
    @request.env['omniauth.auth'] = {
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
    }.with_indifferent_access

    get :create, provider: "google_oauth2"
    assert_redirected_to root_path
  end

  test "should set session['current_user_id'] on login" do
    # cookies[:sharey_session_cookie] = users(:pam).sharey_session_cookie
    pam = users(:pam)
    @request.env['omniauth.auth'] = pam.to_request
    user_count = User.count

    get :create, provider: "google_oauth2"
    assert_equal users(:pam), assigns["current_user"]

    assert_equal pam.id, session['current_user_id']
    assert_equal user_count, User.count
  end

  test "should create a new sharey_session_cookie only on update of user model (tokens)" do
    # cookies[:sharey_session_cookie] = users(:pam).sharey_session_cookie
    pam = users(:pam)
    @request.env['omniauth.auth'] = pam.to_request
    old_sharey_session_cookie = pam.sharey_session_cookie

    get :create, provider: "google_oauth2"
    assert_equal old_sharey_session_cookie, pam.reload.sharey_session_cookie, "nothing has changed, should not update"
    get :destroy

    old_sharey_session_cookie = pam.reload.sharey_session_cookie
    @request.env['omniauth.auth']['credentials']['token'] = "somenewtoken"

    get :create, provider: "google_oauth2"
    refute_equal old_sharey_session_cookie, pam.reload.sharey_session_cookie, "token has changed, should update cookie"

    old_sharey_session_cookie = pam.reload.sharey_session_cookie

    get :create, provider: "google_oauth2"
    assert_equal old_sharey_session_cookie, pam.reload.sharey_session_cookie, "nothing has changed, should not update"
  end


  test "should have access to helper current_user session[from current_user_id]" do
    # cookies[:sharey_session_cookie] = users(:pam).sharey_session_cookie
    session['current_user_id'] = users(:pam).id
    get :index
    assert_equal users(:pam), assigns["current_user"]
  end

  test "should destroy session and redirect to root_path" do
    # cookies[:sharey_session_cookie] = users(:pam).sharey_session_cookie
    session['current_user_id'] = users(:pam).id
    pam = users(:pam)
    @request.env['omniauth.auth'] = pam.to_request

    get :create, provider: "google_oauth2"

    get :destroy
    assert_redirected_to root_path
    assert_nil session['current_user_id']
  end

  test "should update token and refresh_token if response has different values" do
    pam = users(:pam)
    @request.env['omniauth.auth'] = pam.to_request.dup

    @request.env['omniauth.auth']['credentials']["token"] = "newtoken"
    @request.env['omniauth.auth']['credentials']["refresh_token"] = "new_refresh_token"

    get :create, provider: "google_oauth2"

    assert_equal "newtoken", pam.reload.token
    assert_equal "new_refresh_token", pam.reload.refresh_token
  end

end
