require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  should belong_to :user
  should have_many :items

  should validate_presence_of :name
  should validate_presence_of :downcase_name
  should validate_presence_of :user_id
  # A validation below checks that the pair [:user_id, :downcase_name] is unique

  test "should create new category" do
    category = Category.new name:"Here's Some STUPID name", user: users(:pam)
    
    assert category.save, "should create a new category"
    assert_equal "Here's Some STUPID name".downcase, category.downcase_name
    assert_equal "Here's Some STUPID name", category.name
  end

  test "should create new category even if another user has a category of the same name" do
    Category.create name:"Here's Some STUPID name", user: users(:pam)
    category = Category.new name:"Here's Some STUPID name", user: users(:matt)
    
    assert category.save, "should create a new category"
    assert_equal "Here's Some STUPID name".downcase, category.downcase_name
    assert_equal "Here's Some STUPID name", category.name
  end 

  test "should allow a user to create multiple categories" do
    Category.create name:"Here's Some STUPID category", user: users(:matt)
    category = Category.new name:"Here's Some STUPID name", user: users(:matt)
    
    assert category.save, "should allow a user to create multiple categories"
  end 

  test "should not create new category if user has a category of the same name" do
    Category.create name:"Here's Some STUPID name", user: users(:matt)
    category = Category.new name:"Here's Some stupid name", user: users(:matt)
    
    refute category.save, "should not create a new category with same name (case insensitive)"
  end

  test "should not create new category if user has a category but the new category has trailing spaces" do
    Category.create name:"Here's Some STUPID name", user: users(:matt)
    category = Category.new name:"Here's Some stupid name  ", user: users(:matt)
    
    refute category.save, "should not create a new category with trailing spaces"
  end

  test "should not create new category if user has a category but the new category has leading spaces" do
    Category.create name:"Here's Some STUPID name", user: users(:matt)
    category = Category.new name:" Here's Some stupid name  ", user: users(:matt)
    
    refute category.save, "should not create a new category with leading spaces"
  end
end
