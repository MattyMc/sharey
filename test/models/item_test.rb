require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  should belong_to :user
  should belong_to :document
  should belong_to :category
  should have_one :usage_datum
  should belong_to(:from_user).class_name('User').with_foreign_key('from_user_id')
  
  should validate_presence_of :document_id
  should validate_presence_of :user_id
  should validate_presence_of :category_id
  should validate_presence_of :description
end
