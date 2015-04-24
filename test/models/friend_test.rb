require 'test_helper'

class FriendTest < ActiveSupport::TestCase
  should belong_to :user
  should belong_to :receiving_user

  should validate_presence_of :user
  should validate_presence_of :receiving_user
  should_not allow_value(nil).for(:confirmed)

  # Validations -------------------------------------------------------------------------------
  test "should raise an exception if Friend is created with a nil tag and confirmed true" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:pam),
        receiving_user: unregistered_users(:pat),
        tag: nil,
        confirmed: true,
        group_id: nil) }
  end    

  test "should create a new friend with a nil tag and confirmed false" do
    assert Friend.create!(
      user: users(:jay),
      receiving_user: users(:pam),
      tag: nil,
      confirmed: false,
      group_id: nil) 
  end    

  test "should raise an exception if Friend is created with spaces in tag" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:pam),
        receiving_user: users(:jay),
        tag: "@j ay",
        confirmed: true,
        group_id: nil) }
  end  
  
  test "should raise an exception if Friend is created with only an @ as the tag" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:pam),
        receiving_user: users(:jay),
        tag: "@",
        confirmed: true,
        group_id: nil) }
  end

  test "should raise an exception if user and receiving_user are the same" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:pam),
        receiving_user: users(:pam),
        tag: "@jay",
        confirmed: true,
        group_id: nil) }
  end

  test "should raise an exception if tag contains space at front or end" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:pam),
        receiving_user: users(:jay),
        tag: " @jay",
        confirmed: true,
        group_id: nil) }
  end

  test "should raise an exception if tag does not begin with at-sign" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:pam),
        receiving_user: users(:jay), 
        tag: "jay",
        confirmed: true,
        group_id: nil) }
  end

  test "should raise an exception if tag contains space in middle" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:pam),
        receiving_user: users(:jay), 
        tag: " @j ay",
        confirmed: true,
        group_id: nil) }
  end

  test "should raise an exception if tag contains a comma in the middle" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:pam),
        receiving_user: users(:jay),
 
        tag: "@j,ay",
        confirmed: true,
        group_id: nil) }
  end

  test "should raise an exception if tag contains a comma in front" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:pam),
        receiving_user: users(:jay), 
        tag: "@,jay",
        confirmed: true,
        group_id: nil) }
  end

  test "should raise an exception if tag contains a comma at the end" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:pam),
        receiving_user: users(:jay), 
        tag: "@jay,",
        confirmed: true,
        group_id: nil) }
  end

  test "should raise an exception if tag contains a period in the middle" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:pam),
        receiving_user: users(:jay), 
        tag: "@j.ay",
        confirmed: true,
        group_id: nil) }
  end

  test "should raise an exception if tag contains a period in front" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:pam),
        receiving_user: users(:jay), 
        tag: "@.jay",
        confirmed: true,
        group_id: nil) }
  end

  test "should raise an exception if tag contains a period at the end" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:pam),
        receiving_user: users(:jay), 
        tag: "@jay.",
        confirmed: true,
        group_id: nil) }
  end

  test "should raise an exception if user and receiving user already exist" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:matt),
        receiving_user: users(:jay), 
        tag: "@james",
        confirmed: true,
        group_id: nil) }
  end
  
  # -------------------------------------------------------------------------------------------
  # self.create_from_user_email_and_tag -------------------------------------------------------
  # -------------------------------------------------------------------------------------------  
  test "should respond to create_from_user_email_and_tag" do
    assert Friend.respond_to? :create_from_user_email_and_tag
  end

  test "should create a new friend and unregistered_user" do
    unreg_count = UnregisteredUser.count
    user_count = User.count
    friend_count = Friend.count

    friend = Friend.create_from_user_email_and_tag users(:matt), "porkchops@gmail.com", "@Pork"
    friend.save!

    assert_equal unreg_count+1, UnregisteredUser.count 
    assert_equal user_count, User.count 
    assert_equal friend_count+1, Friend.count 
  end

  test "should create a new friend and unregistered_user with proper attributes" do
    unreg_count = UnregisteredUser.count
    user_count = User.count
    friend_count = Friend.count

    friend = Friend.create_from_user_email_and_tag users(:matt), "porkchops@gmail.com", "@Pork"
    friend.save!

    assert_equal "UnregisteredUser", friend.receiving_user_type
    assert_equal "@Pork", friend.tag
    assert_equal users(:matt), friend.user
  end

  test "should create a new friend but not a new user" do
    unreg_count = UnregisteredUser.count
    user_count = User.count
    friend_count = Friend.count

    friend = Friend.create_from_user_email_and_tag users(:jay), "pam@email.com", "@Pam"
    friend.save!

    assert_equal unreg_count, UnregisteredUser.count 
    assert_equal user_count, User.count 
    assert_equal friend_count+1, Friend.count 
  end

  test "should create a new friend but not a new unregistered_user" do
    unreg_count = UnregisteredUser.count
    user_count = User.count
    friend_count = Friend.count

    friend = Friend.create_from_user_email_and_tag users(:jay), "pat@gmail.com", "@Pat"
    friend.save!

    assert_equal unreg_count, UnregisteredUser.count 
    assert_equal user_count, User.count 
    assert_equal friend_count+1, Friend.count 
  end

  test "should raise an exception if tag is already used" do
    unreg_count = UnregisteredUser.count
    user_count = User.count
    friend_count = Friend.count

    friend = Friend.create_from_user_email_and_tag users(:jay), "pam@email.com", "@Pam"
    friend.save!
    assert_raises(ActiveRecord::RecordInvalid) {
      friend = Friend.create_from_user_email_and_tag users(:jay), "pat@gmail.com", "@pam"
      friend.save!
    }
  end

  test "should not create friends if they already exist" do
    unreg_count = UnregisteredUser.count
    user_count = User.count
    friend_count = Friend.count

    assert_raises(ActiveRecord::RecordInvalid) {
      friend = Friend.create_from_user_email_and_tag users(:matt), "pam@email.com", "@pam"
      friend.save!
    }
  end

  test "should find a user even if their email is spelled with capital letters" do
    unreg_count = UnregisteredUser.count
    user_count = User.count
    friend_count = Friend.count

    friend = Friend.create_from_user_email_and_tag users(:jay), "PAM@email.com", "@Pam"
    friend.save!

    assert_equal unreg_count, UnregisteredUser.count 
    assert_equal user_count, User.count 
    assert_equal friend_count+1, Friend.count 
    
    friend = Friend.create_from_user_email_and_tag users(:jay), "pat@GMAIL.com", "@Pat"
    friend.save!

    assert_equal unreg_count, UnregisteredUser.count 
    assert_equal user_count, User.count 
    assert_equal friend_count+2, Friend.count 
  end

  # -------------------------------------------------------------------------------------------
  # find_valid_friends_for_user ---------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  
  test "should return an empty hash and an empty array" do 
    assert_equal [{},[]], Friend.find_valid_friends_for_user(users(:matt), [])
  end

  test "should return one result with no errors" do 
    tags = ["@mau"]
    share_with_users, missing_tags = Friend.find_valid_friends_for_user(users(:matt), tags)

    assert_equal( {"@Mau" => users(:mau)}, share_with_users)
    assert_equal [], missing_tags
  end

  test "should return two results with no errors" do 
    tags = ["@jay", "@mau"]
    share_with_users, missing_tags = Friend.find_valid_friends_for_user(users(:matt), tags)

    assert_equal( {"@Jay" => users(:jay), "@Mau" => users(:mau)}, share_with_users)
    assert_equal [], missing_tags
  end

  test "should return an error message if it can't find a tag" do 
    tags = ["@jay", "@frank_the_tank"]
    share_with_users, missing_tags = Friend.find_valid_friends_for_user(users(:matt), tags)

    assert_equal( {"@Jay" => users(:jay)}, share_with_users)
    assert_equal ["@frank_the_tank"], missing_tags
  end

  test "should return an error message if it can't find a two tags" do 
    tags = ["@jay", "@mau", "@frank_the_tank", "@mancho_man"]
    share_with_users, missing_tags = Friend.find_valid_friends_for_user(users(:matt), tags)

    assert_equal( {"@Jay" => users(:jay), "@Mau" => users(:mau)}, share_with_users)
    assert_equal ["@frank_the_tank", "@mancho_man"], missing_tags
  end

  test "should return an error message if it can't find a three tags" do 
    tags = ["@jay", "@frank_the_tank", "@mancho_man", "@dick"]
    share_with_users, missing_tags = Friend.find_valid_friends_for_user(users(:matt), tags)

    assert_equal( {"@Jay" => users(:jay)}, share_with_users)
    assert_equal ["@frank_the_tank", "@mancho_man", "@dick"], missing_tags
  end

  test "should return an error message if it can't find a five tags" do 
    tags = ["@jay", "@frank", "@tank", "@fart", "@mancho_man", "@dick"]
    share_with_users, missing_tags = Friend.find_valid_friends_for_user(users(:matt), tags)

    assert_equal( {"@Jay" => users(:jay)}, share_with_users)
    assert_equal ["@frank", "@tank", "@fart", "@mancho_man", "@dick"], missing_tags
  end

  test "should return proper friends and tags missing" do 
    tags = ["@Jay", "@frank"]
    share_with_users, missing_tags = Friend.find_valid_friends_for_user(users(:matt), tags)

    assert_equal( {"@Jay" => users(:jay)}, share_with_users)
    assert_equal ["@frank"], missing_tags
  end   

  # -------------------------------------------------------------------------------------------
  # parse_tag_array ---------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  

  test "should return description without tags" do
    description, tag_array = Friend.parse_tag_array "This is a simple description"
    assert_equal "This is a simple description", description
    assert_equal [], tag_array
  end

  test "should return a single tag and the description when tag is at the end" do
    description, tag_array = Friend.parse_tag_array "This is a simple description @matt"
    assert_equal "This is a simple description", description
    assert_equal ["@matt"], tag_array
  end

  test "should return a single tag and the description when tag is in the middle" do
    description, tag_array = Friend.parse_tag_array "This is a simple @matt description"
    assert_equal "This is a simple description", description
    assert_equal ["@matt"], tag_array
  end

  test "should return a single tag and the description when tag is at the fron" do
    description, tag_array = Friend.parse_tag_array "@matt This is a simple description"
    assert_equal "This is a simple description", description
    assert_equal ["@matt"], tag_array
  end

  test "should return multiple tags and the description" do 
    description, tag_array = Friend.parse_tag_array "This is a simple @matt @pam description"
    assert_equal "This is a simple description", description
    assert_equal ["@matt", "@pam"], tag_array
  end

  test "should return multiple tags and the description if tags are dispersed" do 
    description, tag_array = Friend.parse_tag_array "This is a simple @matt  description @pam"
    assert_equal "This is a simple description", description
    assert_equal ["@matt", "@pam"], tag_array
  end

  test "should return multiple tags and the description if tags are near beginning" do 
    description, tag_array = Friend.parse_tag_array "@pam This is a simple description @matt"
    assert_equal "This is a simple description", description
    assert_equal ["@pam", "@matt"], tag_array
  end

  test "should return multiple tags and the description if no spaces between tags" do 
    description, tag_array = Friend.parse_tag_array "@pam This is a simple description @matt"
    assert_equal "This is a simple description", description
    assert_equal ["@pam", "@matt"], tag_array
  end

  test "should return only one tag if it's a duplicate" do 
    description, tag_array = Friend.parse_tag_array "@pam This is a simple description @pam"
    assert_equal "This is a simple description", description
    assert_equal ["@pam"], tag_array
  end

  test "should return no tags if the tag is empty" do 
    description, tag_array = Friend.parse_tag_array "This is a simple description @@ something"
    assert_equal "This is a simple description something", description
    assert_equal [], tag_array
  end

  test "should return one tag if there's an empty tag inside" do 
    description, tag_array = Friend.parse_tag_array "This is a simple description @@matt something"
    assert_equal "This is a simple description something", description
    assert_equal ["@matt"], tag_array
  end

  test "should return tags and description from a complicated string" do 
    description, tag_array = Friend.parse_tag_array "@flying billy bishop @goes@to@war mofo!"
    assert_equal "billy bishop mofo!", description
    assert_equal ["@flying", "@goes", "@to", "@war"], tag_array
  end

  test "should return tags and description from a complicated string with commas" do 
    description, tag_array = Friend.parse_tag_array "This is a simple @matt, @pam description @john,@mau"
    assert_equal "This is a simple description", description
    assert_equal ["@matt", "@pam", "@john", "@mau"], tag_array
  end

  # -------------------------------------------------------------------------------------------
  # testing polymorphic relationship ----------------------------------------------------------
  # -------------------------------------------------------------------------------------------  
  test "should create a new friend with receiving_user an unregistered_user" do
    f = Friend.new(
      user: users(:pam),
      receiving_user: unregistered_users(:pat),
      tag: "@pat",
      confirmed: true,
      group_id: nil)
    f.save!
  end  

  test "should not create a new user friend if tag is already used by an unregistered_user friend" do
    f = Friend.new(
      user: users(:mau),
      receiving_user: users(:pam),
      tag: "@pat",
      confirmed: true,
      group_id: nil) 
    assert_raises(ActiveRecord::RecordInvalid) { f.save! }
  end

  test "should not create a new unregistered_user friend if tag is already used by an user friend" do
    f = Friend.new(
      user: users(:mau),
      receiving_user: unregistered_users(:ben),
      tag: "@jay",
      confirmed: true,
      group_id: nil) 
    assert_raises(ActiveRecord::RecordInvalid) { f.save! }
  end

  test "should not create a new unregistered_user friend if tag is already used by an unregistered_user friend" do
    f = Friend.new(
      user: users(:mau),
      receiving_user: unregistered_users(:ben),
      tag: "@pat",
      confirmed: true,
      group_id: nil) 
    assert_raises(ActiveRecord::RecordInvalid) { f.save! }
  end

  test "should not create a new unregistered_user friend if already friends" do
    f = Friend.new(
      user: users(:mau),
      receiving_user: unregistered_users(:pat),
      tag: "@patrick",
      confirmed: true,
      group_id: nil) 
    assert_raises(ActiveRecord::RecordInvalid) { f.save! }
  end

  test "should not allow creation of a new friendship that already exists" do
    f = Friend.new(
      user: users(:matt),
      receiving_user: users(:pam),
      tag: "@patrick",
      confirmed: true,
      group_id: nil) 
    assert_raises(ActiveRecord::RecordInvalid) { f.save! }
  end

  # -------------------------------------------------------------------------------------------
  # testing tag update ------------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  
  test "should update downcase tag when we update tag" do
    user = users(:matt)
    friend = user.friends.first
    friend.update! tag:"@BLAHHHH"

    assert_equal "@BLAHHHH", friend.reload.tag
  end

end