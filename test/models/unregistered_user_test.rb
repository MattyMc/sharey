require 'test_helper'

class UnregisteredUserTest < ActiveSupport::TestCase
  should validate_presence_of :email
  should have_many :items
  should have_many :usage_datum
  should have_many :friends_with_me

end
