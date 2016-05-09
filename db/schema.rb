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

ActiveRecord::Schema.define(version: 20160508182836) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "license_key"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "applications", ["user_id"], name: "index_applications_on_user_id", using: :btree

  create_table "event_data", force: :cascade do |t|
    t.integer  "application_id"
    t.integer  "host_id"
    t.string   "name"
    t.datetime "timestamp"
    t.integer  "num"
    t.float    "value"
    t.float    "avg"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "event_data", ["application_id"], name: "index_event_data_on_application_id", using: :btree
  add_index "event_data", ["host_id"], name: "index_event_data_on_host_id", using: :btree

  create_table "hosts", force: :cascade do |t|
    t.integer  "application_id"
    t.string   "name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "hosts", ["application_id"], name: "index_hosts_on_application_id", using: :btree

  create_table "metrics", force: :cascade do |t|
    t.integer  "application_id"
    t.integer  "host_id"
    t.string   "end_point"
    t.string   "name"
    t.datetime "started_at"
    t.string   "transaction_id"
    t.text     "payload"
    t.float    "duration"
    t.float    "exclusive_duration"
    t.float    "db_duration"
    t.float    "view_duration"
    t.float    "gc_duration"
    t.integer  "request_id"
    t.integer  "parent_id"
    t.string   "action"
    t.string   "category"
  end

  create_table "raw_data", force: :cascade do |t|
    t.integer  "application_id"
    t.integer  "host_id"
    t.string   "method"
    t.text     "body"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_foreign_key "applications", "users"
  add_foreign_key "event_data", "applications"
  add_foreign_key "event_data", "hosts"
  add_foreign_key "hosts", "applications"
end
