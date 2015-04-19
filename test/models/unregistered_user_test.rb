require 'test_helper'

class UnregisteredUserTest < ActiveSupport::TestCase
  should validate_presence_of :email
end
