# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150109021844) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string  "name",          null: false
    t.string  "downcase_name", null: false
    t.integer "user_id",       null: false
  end

  add_index "categories", ["user_id", "downcase_name"], name: "index_categories_on_user_id_and_downcase_name", unique: true, using: :btree
  add_index "categories", ["user_id"], name: "index_categories_on_user_id", using: :btree

  create_table "documents", force: :cascade do |t|
    t.string   "url",           null: false
    t.string   "title"
    t.integer  "originator_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "items", force: :cascade do |t|
    t.integer  "document_id",      null: false
    t.integer  "user_id",          null: false
    t.integer  "from_user_id"
    t.integer  "category_id"
    t.string   "description",      null: false
    t.string   "original_request", null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "items", ["category_id"], name: "index_items_on_category_id", using: :btree
  add_index "items", ["document_id"], name: "index_items_on_document_id", using: :btree
  add_index "items", ["from_user_id"], name: "index_items_on_from_user_id", using: :btree
  add_index "items", ["user_id"], name: "index_items_on_user_id", using: :btree

  create_table "usage_data", force: :cascade do |t|
    t.integer  "item_id",                     null: false
    t.boolean  "viewed",      default: true
    t.boolean  "deleted",     default: false
    t.integer  "click_count", default: 0
    t.boolean  "shared",      default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "usage_data", ["item_id"], name: "index_usage_data_on_item_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "uid"
    t.string   "name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "image"
    t.string   "token"
    t.string   "refresh_token"
    t.string   "sharey_session_cookie"
    t.datetime "expires_at"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", unique: true, using: :btree

  add_foreign_key "categories", "users"
  add_foreign_key "items", "categories"
  add_foreign_key "items", "documents"
  add_foreign_key "items", "users"
  add_foreign_key "usage_data", "items"
end
