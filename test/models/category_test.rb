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

  # -------------------------------------------------------------------------------------------
  # Category.first_or_initialize_with_name_and_user -------------------------------------------
  # -------------------------------------------------------------------------------------------
  test "should create a new category with new name and new user" do 
    user = users(:matt)
    cat_count = Category.count
    category = Category.first_or_initialize_with_name_and_user "Food", user

    assert_equal Category, category.class
    assert_equal cat_count+1, Category.count
    assert_equal(
      ["Food", "food", user],
      [category.name, category.downcase_name, category.user])
  end

  test "should return nil if name is empty string or nil" do 
    user = users(:matt)
    cat_count = Category.count
    category = Category.first_or_initialize_with_name_and_user "", user

    assert category.nil?
    assert_equal cat_count, Category.count

    cat_count = Category.count
    category = Category.first_or_initialize_with_name_and_user nil, user

    assert category.nil?
    assert_equal cat_count, Category.count
  end

  test "should create a new category with used name for a new user" do 
    user = users(:matt)
    cat_count = Category.count
    category = Category.first_or_initialize_with_name_and_user "Funny", user # Funny belongs to Pam

    assert_equal Category, category.class
    assert_equal cat_count+1, Category.count
    assert_equal(
      ["Funny", "funny", user],
      [category.name, category.downcase_name, category.user])
  end

  test "should not create a new category with same user and same name" do 
    user = users(:pam)
    cat_count = Category.count
    category = Category.first_or_initialize_with_name_and_user "Funny ", user

    assert_equal Category, category.class
    assert_equal cat_count, Category.count
    assert_equal(
      ["Funny", "funny", user],
      [category.name, category.downcase_name, category.user])
  end
end
