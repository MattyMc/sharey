# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Code below creates data from fixtures
if (Rails.env.development?)
  # Destroy all data
  UsageDatum.destroy_all
  Item.destroy_all
  Document.destroy_all
  Category.destroy_all
  Friend.destroy_all
  User.destroy_all

  require 'active_record/fixtures'
  ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "categories")
  ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "documents")
  ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "friends")
  ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "items")
  ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "unregistered_users")
  ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "usage_data")
  ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "users")
end
