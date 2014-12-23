require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should validate_presence_of :first_name
  should validate_presence_of :last_name
  should validate_presence_of :email
  should validate_presence_of :image_url
  should validate_presence_of :access_token
  should validate_presence_of :refresh_token
  should validate_presence_of :expires_at
  should validate_presence_of :uid

  test "should create a new user" do
    user = User.create!(
      first_name: "Marco",
      last_name: "Polo",
      email: "marco@polo.com",
      uid: "1237389427398",
      image_url: "https://www.gooogle.com/someimage",
      access_token: "132414245",
      refresh_token: "23eff3r23rfwe",
      expires_at: Time.at(1419285290).to_datetime
    )
    assert User.find_by_email("marco@polo.com")
  end

  test "should create a new user from Google's callback params" do
    auth_params = {}
    auth_params["uid"] = "1237389427398"

    auth_params["info"] =
      {"first_name" => "Peter",
      "last_name" => "Pan",
      "email" => "matt@gmail.com",
      "image" => "http://www.my.com/image"
    }
    auth_params['credentials'] = {
      "token" => "23483742894327482",
      "refresh_token" => "hjkdhsf837249832",
      "expires_at" => 1419290669
    }

    assert User.respond_to?( :find_or_create_from_google_callback), "User.create_from_google_callback should exist" 

    user = User.find_or_create_from_google_callback(auth_params)
    assert_equal User.find_by_uid("1237389427398"), user
  end

  test "should not create a new user with existing uid" do
    auth_params = {}
    auth_params["uid"] = "1237389427398"

    auth_params["info"] =
      {"first_name" => "Peter",
      "last_name" => "Pan",
      "email" => "matt@gmail.com",
      "image" => "http://www.my.com/image"
    }
    auth_params['credentials'] = {
      "token" => "23483742894327482",
      "refresh_token" => "hjkdhsf837249832",
      "expires_at" => 1419290669
    }

    assert_nil User.find_by_uid(auth_params["uid"])
    User.find_or_create_from_google_callback(auth_params)
    user_count = User.count

    user = User.find_or_create_from_google_callback(auth_params)
    assert_equal user_count, User.count
  end  


  test "should return existing user with updated token from callback params" do
    auth_params = {}
    auth_params["uid"] = "1237389427398"

    auth_params["info"] =
      {"first_name" => "Peter",
      "last_name" => "Pan",
      "email" => "matt@gmail.com",
      "image" => "http://www.my.com/image"
    }
    auth_params['credentials'] = {
      "token" => "23483742894327482",
      "refresh_token" => "hjkdhsf837249832",
      "expires_at" => 1419290669
    }

    assert_nil User.find_by_uid(auth_params["uid"])
    User.find_or_create_from_google_callback(auth_params)

    auth_params['credentials']['token'] = "478392578235923"

    user = User.find_or_create_from_google_callback(auth_params)
    assert_equal "478392578235923", user.access_token
  end  

  test "should not create a new user with a uid that has already been taken" do
    user1 = User.new(
      first_name: "Marco",
      last_name: "Polo",
      email: "marco@polo.com",
      uid: "1237389427398",
      image_url: "https://www.gooogle.com/someimage",
      access_token: "132414245",
      refresh_token: "23eff3r23rfwe",
      expires_at: Time.at(1419285290).to_datetime
    )
    user1.save

    user = User.new(
      first_name: "Matt",
      last_name: "Case",
      email: "matt@polo.com",
      uid: "1237389427398",
      image_url: "https://www.gooogle.com/some",
      access_token: "132414245",
      refresh_token: "23eff3r23rfwe",
      expires_at: Time.at(1419285290).to_datetime
    )
    
    assert_raises(ActiveRecord::RecordInvalid) {user.save!}
  end

  test "should not create a new user with a nil or empty uid" do
    user1 = User.new(
      first_name: "Marco",
      last_name: "Polo",
      email: "marco@polo.com",
      uid: "",
      image_url: "https://www.gooogle.com/someimage",
      access_token: "132414245",
      refresh_token: "23eff3r23rfwe",
      expires_at: Time.at(1419285290).to_datetime
    )
    assert_raises(ActiveRecord::RecordInvalid) {user1.save!}

    user = User.new(
      first_name: "Matt",
      last_name: "Case",
      email: "matt@polo.com",
      uid: nil,
      image_url: "https://www.gooogle.com/some",
      access_token: "132414245",
      refresh_token: "23eff3r23rfwe",
      expires_at: Time.at(1419285290).to_datetime
    )
    
    assert_raises(ActiveRecord::RecordInvalid) {user.save!}
  end

end
