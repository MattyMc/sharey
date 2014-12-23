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

    user = User.find_by_uid result_hash["uid"]

    assert_equal User.find_by_uid("1237389427398"), assigns["user"]
    assert User.find_by_email(result_hash[:email]), "Should create a user"
    assert_response :success
  end

  # test "should redirect to home page after creating new user" do
  #   @request.env['omniauth.auth'] = {}

  #   @request.env['omniauth.auth']["info"] =
  #     {"first_name" => "Peter",
  #     "last_name" => "Pan",
  #     "email" => "matt@gmail.com",
  #     "image" => "http://www.my.com/image"
  #   }
  #   @request.env['omniauth.auth']['credentials'] = {
  #     "token" => "23483742894327482",
  #     "refresh_token" => "hjkdhsf837249832",
  #     "expires_at" => 1419290669
  #   }

  #   get :create 

  #   assert_equal result_hash, assigns["auth"]
  #   assert User.find_by_email( result_hash["email"]), "Should create a user"
  #   assert_response :success
  # end



  # test "should throw an error if request hash is not defined" do
  #   user_count = User.count

  #   assert_raise(RuntimeError) { get :create }

  # end

  

end
