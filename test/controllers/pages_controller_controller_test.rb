require 'test_helper'

class PagesControllerControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end

  test "should get my_friends" do
    get :my_friends
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
