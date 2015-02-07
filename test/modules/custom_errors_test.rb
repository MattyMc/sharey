require 'test_helper'
require 'custom_errors.rb'

class CustomErrorTest < ActiveSupport::TestCase
  include CustomErrors


  # -------------------------------------------------------------------------------------------
  # Tests for UserNotFound --------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------

  test "should raise UserNotFound" do
    assert_raises(UserNotFound) {
      raise UserNotFound
    }
  end

  test "should raise UserNotFound and respond with properly structured response" do
    e = assert_raises(UserNotFound) {
      raise UserNotFound
    }

    assert_equal Hash,   e.modal_response["data"].class, e.modal_response.inspect
    assert_equal String, e.modal_response["data"]["heading"].class
    assert_equal String, e.modal_response["data"]["subheading"].class
    assert_equal Array,  e.modal_response["data"]["messages"].class
    assert_operator 1, :<=, e.modal_response["data"]["messages"].count, "should be at least one error message"
  end


  # -------------------------------------------------------------------------------------------
  # Tests for InvalidItemParams ---------------------------------------------------------------
  # -------------------------------------------------------------------------------------------

  test "should raise InvalidItemParams" do
    assert_raises(InvalidItemParams) {
      raise InvalidItemParams
    }
  end

  test "should raise InvalidItemParams and respond with properly structured response" do
    e = assert_raises(InvalidItemParams) {
      raise InvalidItemParams
    }

    assert_equal "modal", e.modal_response["type"]
    assert_equal Hash,   e.modal_response["data"].class
    assert_equal String, e.modal_response["data"]["heading"].class
    assert_equal String, e.modal_response["data"]["subheading"].class
    assert_equal Array,  e.modal_response["data"]["messages"].class
    assert_operator 1, :<=, e.modal_response["data"]["messages"].count, "should be at least one error message"
  end


  # -------------------------------------------------------------------------------------------
  # Tests for NoItemsFound --------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------

  test "should raise NoItemsFound" do
    assert_raises(NoItemsFound) {
      raise NoItemsFound
    }
  end

  test "should raise NoItemsFound and respond with properly structured response" do
    e = assert_raises(NoItemsFound) {
      raise NoItemsFound
    }

    assert_equal "modal", e.modal_response["type"]
    assert_equal Hash,   e.modal_response["data"].class
    assert_equal String, e.modal_response["data"]["heading"].class
    assert_equal String, e.modal_response["data"]["subheading"].class
    assert_equal Array,  e.modal_response["data"]["messages"].class
    assert_operator 1, :<=, e.modal_response["data"]["messages"].count, "should be at least one error message"
  end


  # -------------------------------------------------------------------------------------------
  # Tests for NoItemsFound --------------------------------------------------------------------
  # -------------------------------------------------------------------------------------------

  test "should raise ItemNotFoundForUser" do
    assert_raises(ItemNotFoundForUser) {
      raise ItemNotFoundForUser
    }
  end

  test "should raise ItemNotFoundForUser and respond with properly structured response" do
    e = assert_raises(ItemNotFoundForUser) {
      raise ItemNotFoundForUser
    }

    assert_equal "modal", e.modal_response["type"]
    assert_equal Hash,   e.modal_response["data"].class
    assert_equal String, e.modal_response["data"]["heading"].class
    assert_equal String, e.modal_response["data"]["subheading"].class
    assert_equal Array,  e.modal_response["data"]["messages"].class
    assert_operator 1, :<=, e.modal_response["data"]["messages"].count, "should be at least one error message"
  end

end