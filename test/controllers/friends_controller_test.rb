require 'test_helper'

class FriendsControllerTest < ActionController::TestCase
  # Easily test response parameters using json_response['result']
  def json_response
    ActiveSupport::JSON.decode @response.body
  end

  test "should not create a friend from existing friends" do
    session['current_user_id'] = users(:matt).id
    friend_count = users(:matt).friends.count

    post :create, friend: { tag: "@Charles", email: "pam@email.com" }

    assert_equal friend_count, users(:matt).friends.count
    refute json_response.empty?, json_response
  end

  test "should create a friend from a nonexistent email address" do
    session['current_user_id'] = users(:matt).id
    friend_count = users(:matt).friends.count
    unreg_count = UnregisteredUser.count
    user_count = User.count

    assert_difference('Friend.count') do
      post :create, friend: { tag: "@Charles", email: "charles@gmail.com" }
      assert_response :success
      assert_equal friend_count+1, Friend.count
      assert_equal unreg_count+1, UnregisteredUser.count
      assert_equal user_count, User.count
    end
  end

  test "should create a friend from a registered user" do
    session['current_user_id'] = users(:jay).id
    friend_count = users(:jay).friends.count
    unreg_count = UnregisteredUser.count
    user_count = User.count

    assert_difference('Friend.count') do
      post :create, friend: { tag: "@Pam", email: "pam@email.com" }
      assert_response :success
      assert_equal friend_count+1, Friend.count
      assert_equal unreg_count, UnregisteredUser.count
      assert_equal user_count+1, User.count
    end
  end

  test "should create a friend from an unregistered user" do
    session['current_user_id'] = users(:jay).id
    friend_count = users(:jay).friends.count
    unreg_count = UnregisteredUser.count
    user_count = User.count

    assert_difference('Friend.count') do
      post :create, friend: { tag: "@Pat", email: "pat@gmail.com" }
      assert_response :success
      assert_equal friend_count+1, Friend.count
      assert_equal unreg_count, UnregisteredUser.count
      assert_equal user_count, User.count
    end
  end

  test "should not create a friend from a bad email address" do
    session['current_user_id'] = users(:jay).id
    friend_count = users(:jay).friends.count
    unreg_count = UnregisteredUser.count
    user_count = User.count

    assert_difference('Friend.count') do
      post :create, friend: { tag: "@Pat", email: "sillyquackquack.com" }
      assert_response :failure
      assert_equal friend_count, Friend.count
      assert_equal unreg_count, UnregisteredUser.count
      assert_equal user_count, User.count
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
