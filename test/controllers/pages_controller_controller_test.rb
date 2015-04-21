require 'test_helper'

class PagesControllerControllerTest < ActionController::TestCase

  test "should route root_path to pages#home" do
    assert_routing({ path: '/', method: :get }, { controller: 'pages_controller', action: 'home' })
  end  

  # -------------------------------------------------------------------------------------------
  # get my_friends  ---------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  
  test "should get my_friends" do
    get :my_friends
    assert_response :success
  end

  # test "should return nothing if provided a users valid cookie" do 
  #   cookies[:sharey_session_cookie] = users(:matt).sharey_session_cookie
  #   get :check_login
  #   assert_response :success
  # end  

  # test "should return a modal if users cookie does not exist" do 
  #   cookies[:sharey_session_cookie] = users(:matt).sharey_session_cookie + "blah"
  #   get :check_login
  #   assert_response :bad_request
  #   assert_equal "modal", json_response['type']
  # end

  test "should return matts friends if logged in" do 
    session['current_user_id'] = users(:matt).id

    get :my_friends
    assert_response :success
    assert_equal users(:matt).friends, assigns["friends"]
  end

  test "should redirect user to login if no user_id" do 
    session['current_user_id'] = "12312412412"

    get :my_friends
    assert_redirected_to :root_path
    # assert_flash
  end

  test "should get home" do
    get :home
    assert_response :success
  end


  test "should get saved_items" do
    get :saved_items
    assert_response :success
  end

  test "should get about" do
    get :about
    assert_response :success
  end

end
