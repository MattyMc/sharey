require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  should have_many :items

  should validate_presence_of :name
  should validate_presence_of :low_case_name
end
