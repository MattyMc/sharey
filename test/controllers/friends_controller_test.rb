require 'test_helper'

class FriendsControllerTest < ActionController::TestCase
  # Easily test response parameters using json_response['result']
  def json_response
    ActiveSupport::JSON.decode @response.body
  end

  # -------------------------------------------------------------------------------------------
  # post :create ------------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  

  test "should not create a friend from existing friends" do
    session['current_user_id'] = users(:matt).id
    friend_count = users(:matt).friends.count

    post :create, tag: "@Charles", email: "pam@email.com"

    assert_equal friend_count, users(:matt).friends.count
  end

  test "should create a friend from a nonexistent email address" do
    session['current_user_id'] = users(:matt).id
    friend_count = users(:matt).friends.count
    unreg_count = UnregisteredUser.count
    user_count = User.count

    post :create, tag: "@Charles", email: "charles@gmail.com"
    assert_redirected_to my_friends_path
    assert_equal friend_count+1, users(:matt).friends.count
    assert_equal unreg_count+1, UnregisteredUser.count
    assert_equal user_count, User.count
    
  end

  test "should create a friend from a registered user" do
    session['current_user_id'] = users(:jay).id
    friend_count = users(:jay).friends.count
    unreg_count = UnregisteredUser.count
    user_count = User.count
    
    post :create, tag: "@Pam", email: "pam@email.com"
    assert_redirected_to my_friends_path
    assert_equal friend_count+1, users(:jay).friends.count
    assert_equal unreg_count, UnregisteredUser.count
    assert_equal user_count, User.count    
  end

  test "should create a friend from an existing friend who is an unregistered user" do
    session['current_user_id'] = users(:jay).id
    friend_count = users(:jay).friends.count
    unreg_count = UnregisteredUser.count
    user_count = User.count
   
    post :create, tag: "@Pat", email: "pat@gmail.com"
    assert_redirected_to my_friends_path
    assert_equal friend_count+1, users(:jay).friends.count
    assert_equal unreg_count, UnregisteredUser.count
    assert_equal user_count, User.count
  end

  test "should not create a friend from a bad email address" do
    session['current_user_id'] = users(:jay).id
    friend_count = users(:jay).friends.count
    unreg_count = UnregisteredUser.count
    user_count = User.count

    post :create, tag: "@Pat", email: "sillyquackquack.com"
    # assert_response :unprocessable_entity
    assert_equal friend_count, users(:jay).friends.count
    assert_equal unreg_count, UnregisteredUser.count
    assert_equal user_count, User.count
  end

  test "should not create a friend if the user is not logged in" do
    session['current_user_id'] = 123151512224
    friend_count = Friend.count
    unreg_count = UnregisteredUser.count
    user_count = User.count

    post :create, tag: "@Pat", email: "sillyquackquack.com"
    # assert_response :unprocessable_entity
    assert_equal friend_count, Friend.count
    assert_equal unreg_count, UnregisteredUser.count
    assert_equal user_count, User.count
  end

  # -------------------------------------------------------------------------------------------
  # patch :update -----------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  

  test "should not update friend if no user is defined" do 
    friend = friends(:matt_jay)
    patch :update, id:friend.id, friend: {tag: "@JAMES"}

    refute_equal "@JAMES", friends(:matt_jay).reload.tag
  end  

  test "should not update friend if wrong user is defined" do 
    session['current_user_id'] = users(:jay).id
    friend = friends(:matt_jay)
    patch :update, id:friend.id, friend: {tag: "@JAMES"}

    refute_equal "@JAMES", friends(:matt_jay).reload.tag
  end  

  test "should update friend and render message" do 
    session['current_user_id'] = users(:matt).id
    friend = friends(:matt_jay)
    patch :update, id:friend.id, friend: {tag: "@JAMES"}

    assert_redirected_to my_friends_path
    assert_equal "@JAMES", friends(:matt_jay).reload.tag, "should update tag"
  end

  test "should update confirmed attribute if tag was nil" do 
    session['current_user_id'] = users(:pam).id
    Friend.create! user:users(:pam), receiving_user:users(:jay), tag:nil, confirmed: false 

    friend = Friend.last
    patch :update, id:friend.id, friend: {tag: "@JAMES"}

    assert_redirected_to my_friends_path
    assert_equal "@JAMES", Friend.last.tag, "should update tag"
    assert_equal true, Friend.last.confirmed, "should confirmed attribute"
  end

  # -------------------------------------------------------------------------------------------
  # delete :destroy ---------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  

  test "should not destroy friend if no user is defined" do 
    friend = friends(:matt_jay)
    friend_count = Friend.count
    delete :destroy, id:friend.id

    refute_nil Friend.where(user: users(:matt), receiving_user:users(:jay)).first, "Should not have been destroyed"
    assert_equal friend_count, Friend.count
  end  

  test "should not destroy friend if wrong user is defined" do 
    session['current_user_id'] = users(:jay).id
    friend = friends(:matt_jay)
    friend_count = Friend.count
    delete :destroy, id:friend.id

    refute_nil Friend.where(user: users(:matt), receiving_user:users(:jay)).first, "Should not have been destroyed"
    assert_equal friend_count, Friend.count
  end  

  test "should destroy friend and render message" do 
    session['current_user_id'] = users(:matt).id
    friend = friends(:matt_jay)
    friend_count = Friend.count
    delete :destroy, id:friend.id

    assert_nil Friend.where(user: users(:matt), receiving_user:users(:jay)).first, "Should have been destroyed"
    assert_equal friend_count-1, Friend.count
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
