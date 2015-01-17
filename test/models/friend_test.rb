require 'test_helper'

class FriendTest < ActiveSupport::TestCase
  should belong_to :user
  should belong_to(:receiving_user).class_name('User').with_foreign_key('receiving_user_id')

  should validate_presence_of :downcase_tag
  should validate_presence_of :tag
  should validate_presence_of :confirmed

  # Validations -------------------------------------------------------------------------------
  test "should raise an exception if Friend is created with spaces in downcase_tag" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:pam),
        receiving_user: users(:jay),
        downcase_tag: " @jay",
        tag: "@jay",
        confirmed: true,
        group_id: nil) }
  end

  test "should raise an exception if user and receiving_user are the same" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:pam),
        receiving_user: users(:pam),
        downcase_tag: "@jay",
        tag: "@jay",
        confirmed: true,
        group_id: nil) }
  end


  test "should raise an exception if tag contains space at front or end" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:pam),
        receiving_user: users(:jay),
        downcase_tag: "@jay",
        tag: " @jay",
        confirmed: true,
        group_id: nil) }
  end

  test "should raise an exception if tag contains space in middle" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:pam),
        receiving_user: users(:jay),
        downcase_tag: "@jay",
        tag: " @j ay",
        confirmed: true,
        group_id: nil) }
  end


  test "should raise an exception if downcase_tag contains space in middle" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:pam),
        receiving_user: users(:jay),
        downcase_tag: "@j ay",
        tag: "@jay",
        confirmed: true,
        group_id: nil) }
  end

  test "should raise an exception if user and receiving user already exist" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:matt),
        receiving_user: users(:jay),
        downcase_tag: "@james",
        tag: "@james",
        confirmed: true,
        group_id: nil) }
  end

  test "should automatically set downcase_tag on create" do
    assert_raises(ActiveRecord::RecordInvalid){
      Friend.create!(
        user: users(:pam),
        receiving_user: users(:jay),
        tag: "@Jay",
        confirmed: true,
        group_id: nil) }
  end

  # -------------------------------------------------------------------------------------------
  # find_valid_friends_for_user ---------------------------------------------------------------
  # -------------------------------------------------------------------------------------------  
  test "should return nil" do 
    assert Friend.find_valid_friends_for_user(users(:matt), []).nil?
  end

  test "should return one result with no errors" do 
    tags = ["@mau"]
    share_with_user_ids, tag_errors = Friend.find_valid_friends_for_user(users(:matt), tags)

    assert_equal [users(:mau).id], share_with_user_ids
    assert_equal nil, tag_errors
  end

  test "should return two results with no errors" do 
    tags = ["@jay", "@mau"]
    share_with_user_ids, tag_errors = Friend.find_valid_friends_for_user(users(:matt), tags)

    assert_equal [users(:jay).id, users(:mau).id], share_with_user_ids
    assert_equal nil, tag_errors
  end

  test "should return an error message if it can't find a tag" do 
    tags = ["@jay", "@frank_the_tank"]
    share_with_user_ids, tag_errors = Friend.find_valid_friends_for_user(users(:matt), tags)

    assert_equal [users(:jay).id], share_with_user_ids
    assert_equal "Sharey couldn't find any tags named @frank_the_tank", tag_errors
  end

  test "should return an error message if it can't find a two tags" do 
    tags = ["@jay", "@mau", "@frank_the_tank", "@mancho_man"]
    share_with_user_ids, tag_errors = Friend.find_valid_friends_for_user(users(:matt), tags)

    assert_equal [users(:jay).id, users(:mau).id], share_with_user_ids
    assert_equal "Sharey couldn't find any tags named @frank_the_tank or @mancho_man", tag_errors
  end

  test "should return an error message if it can't find a three tags" do 
    tags = ["@jay", "@frank_the_tank", "@mancho_man", "@dick"]
    share_with_user_ids, tag_errors = Friend.find_valid_friends_for_user(users(:matt), tags)

    assert_equal [users(:jay).id], share_with_user_ids
    assert_equal "Sharey couldn't find any tags named @frank_the_tank, @mancho_man, or @dick", tag_errors
  end

  test "should return an error message if it can't find a five tags" do 
    tags = ["@jay", "@frank", "@tank", "@fart", "@mancho_man", "@dick"]
    share_with_user_ids, tag_errors = Friend.find_valid_friends_for_user(users(:matt), tags)

    assert_equal [users(:jay).id], share_with_user_ids
    assert_equal "Sharey couldn't find any tags named @frank, @tank, @fart, @mancho_man, or @dick", tag_errors
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

  test "should return a single tag and the descriptionwhen tag is in the middle" do
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
end
