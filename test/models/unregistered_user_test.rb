require 'test_helper'

class UnregisteredUserTest < ActiveSupport::TestCase
  should validate_presence_of :email
  should have_many :items
  should have_many :usage_datum
  should have_many :friends_with_me

  test "should not allow a new UnregisteredUser with the same email address" do
    user = unregistered_users(:pat)
    assert_raises(ActiveRecord::RecordInvalid) { UnregisteredUser.create! email:user.email.upcase }
  end
end
