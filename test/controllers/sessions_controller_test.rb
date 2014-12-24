require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  # test "should get new" do
    
  #   assert_response :success
  # end

  test "should create a new user on first login" do
    @request.env['omniauth.auth'] = {}
    @request.env['omniauth.auth']["uid"] = "1237389427398"

    @request.env['omniauth.auth']["info"] =
      {"first_name" => "Peter",
      "last_name" => "Pan",
      "email" => "matt@gmail.com",
      "image" => "http://www.my.com/image"
    }
    @request.env['omniauth.auth']['credentials'] = {
      "token" => "23483742894327482",
      "refresh_token" => "hjkdhsf837249832",
      "expires_at" => 1419290669
    }

    result_hash = {
      first_name: "Peter",
      last_name: "Pan",
      email: "matt@gmail.com",
      uid: "1237389427398",
      image_url: "http://www.my.com/image",
      access_token: "23483742894327482",
      refresh_token: "hjkdhsf837249832",
      expires_at: Time.at(1419290669).to_datetime
    }

    get :create 

    user = User.find_by_uid result_hash[:uid]

    assert_equal User.find_by_uid("1237389427398"), assigns["current_user"]
    assert User.find_by_email(result_hash[:email]), "Should create a user"
  end

  test "should set cookies['sharey_session_cookie'] upon creating a new user" do
    @request.env['omniauth.auth'] = {}
    @request.env['omniauth.auth']["uid"] = "1237389427398"

    @request.env['omniauth.auth']["info"] =
      {"first_name" => "Peter",
      "last_name" => "Pan",
      "email" => "matt@gmail.com",
      "image" => "http://www.my.com/image"
    }
    @request.env['omniauth.auth']['credentials'] = {
      "token" => "23483742894327482",
      "refresh_token" => "hjkdhsf837249832",
      "expires_at" => 1419290669
    }

    result_hash = {
      first_name: "Peter",
      last_name: "Pan",
      email: "matt@gmail.com",
      uid: "1237389427398",
      image_url: "http://www.my.com/image",
      access_token: "23483742894327482",
      refresh_token: "hjkdhsf837249832",
      expires_at: Time.at(1419290669).to_datetime
    }

    get :create 

    user = User.find_by_uid result_hash[:uid]
    # session[:current_user_id] = 1

    assert_equal user.sharey_session_cookie, cookies[:sharey_session_cookie]
  end

  test "should redirect to root path" do
    @request.env['omniauth.auth'] = {}
    @request.env['omniauth.auth']["uid"] = "1237389427398"

    @request.env['omniauth.auth']["info"] =
      {"first_name" => "Peter",
      "last_name" => "Pan",
      "email" => "matt@gmail.com",
      "image" => "http://www.my.com/image"
    }
    @request.env['omniauth.auth']['credentials'] = {
      "token" => "23483742894327482",
      "refresh_token" => "hjkdhsf837249832",
      "expires_at" => 1419290669
    }

    result_hash = {
      first_name: "Peter",
      last_name: "Pan",
      email: "matt@gmail.com",
      uid: "1237389427398",
      image_url: "http://www.my.com/image",
      access_token: "23483742894327482",
      refresh_token: "hjkdhsf837249832",
      expires_at: Time.at(1419290669).to_datetime
    }

    get :create 
    assert_redirected_to root_path
  end

  test "should set session['current_user_id']" do
    # cookies[:sharey_session_cookie] = users(:pam).sharey_session_cookie
    pam = users(:pam)
    @request.env['omniauth.auth'] = {}
    @request.env['omniauth.auth']["uid"] = pam.uid

    @request.env['omniauth.auth']["info"] =
      {"first_name" => pam.first_name,
      "last_name" => pam.last_name,
      "email" => pam.email,
      "image" => pam.image_url
    }
    @request.env['omniauth.auth']['credentials'] = {
      "token" => pam.access_token,
      "refresh_token" => pam.refresh_token,
      "expires_at" => 4785934578
    }

    get :create
    assert_equal users(:pam), assigns["current_user"]
  end

  test "should create a new sharey_session_cookie on each new login" do
    # cookies[:sharey_session_cookie] = users(:pam).sharey_session_cookie
    pam = users(:pam)
    @request.env['omniauth.auth'] = {}
    @request.env['omniauth.auth']["uid"] = pam.uid

    @request.env['omniauth.auth']["info"] =
      {"first_name" => pam.first_name,
      "last_name" => pam.last_name,
      "email" => pam.email,
      "image" => pam.image_url
    }
    @request.env['omniauth.auth']['credentials'] = {
      "token" => pam.access_token,
      "refresh_token" => pam.refresh_token,
      "expires_at" => 4785934578
    }
    old_sharey_session_cookie = pam.sharey_session_cookie

    get :create
    refute_equal old_sharey_session_cookie, pam.reload.sharey_session_cookie
    get :destroy

    old_sharey_session_cookie = pam.reload.sharey_session_cookie

    get :create
    refute_equal old_sharey_session_cookie, pam.reload.sharey_session_cookie

    old_sharey_session_cookie = pam.reload.sharey_session_cookie

    get :create
    refute_equal old_sharey_session_cookie, pam.reload.sharey_session_cookie
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
    @request.env['omniauth.auth'] = {}
    @request.env['omniauth.auth']["uid"] = pam.uid

    @request.env['omniauth.auth']["info"] =
      {"first_name" => pam.first_name,
      "last_name" => pam.last_name,
      "email" => pam.email,
      "image" => pam.image_url
    }
    @request.env['omniauth.auth']['credentials'] = {
      "token" => pam.access_token,
      "refresh_token" => pam.refresh_token,
      "expires_at" => 4785934578
    }
    old_sharey_session_cookie = pam.sharey_session_cookie
    get :create

    get :destroy
    assert_redirected_to root_path
  end

end
