require 'test_helper'

class FriendsControllerTest < ActionController::TestCase
  # Easily test response parameters using json_response['result']
  def json_response
    ActiveSupport::JSON.decode @response.body
  end

  test "should not create a friend" do
    session['current_user_id'] = users(:matt).id
    friend_count = users(:matt).friends.count

    post :create, friend: { tag: "@Charles", email: "charles@gmail.com" }

    assert_equal friend_count, users(:matt).friends.count
    refute json_response.empty?, json_response
  end

  test "should create a friend" do
    session['current_user_id'] = users(:mau).id

    assert_difference('Friend.count') do
      post :create, friend: { tag: "@Charles", email: "charles@gmail.com" }
      assert json_response.empty?, json_response
    end

  end

  # test "should update friend" do
  #   patch :update, id: @friend, friend: { age: @friend.age, name: @friend.name, tag: @friend.tag }
  #   assert_redirected_to friend_path(assigns(:friend))
  # end

  # test "should destroy friend" do
  #   assert_difference('Friend.count', -1) do
  #     delete :destroy, id: @friend
  #   end

  #   assert_redirected_to friends_path
  # end

end
