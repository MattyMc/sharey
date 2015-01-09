require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  should have_many :items
  should belong_to(:originator).class_name('User')

  should validate_presence_of :url
  should validate_uniqueness_of :url
  should validate_presence_of :originator_id
end
