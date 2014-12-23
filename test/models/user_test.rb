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

  test "should not create a new user with uid of a different user" do
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


end
