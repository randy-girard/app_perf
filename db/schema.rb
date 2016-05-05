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

ActiveRecord::Schema.define(version: 20160504131253) do

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

  create_table "metrics", force: :cascade do |t|
    t.integer  "application_id"
    t.integer  "raw_datum_id"
    t.string   "name"
    t.string   "scope"
    t.datetime "timestamp"
    t.float    "value"
    t.text     "raw_data"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "metrics", ["application_id"], name: "index_metrics_on_application_id", using: :btree
  add_index "metrics", ["raw_datum_id"], name: "index_metrics_on_raw_datum_id", using: :btree

  create_table "raw_data", force: :cascade do |t|
    t.integer  "application_id"
    t.string   "method"
    t.text     "body"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "system_metrics", force: :cascade do |t|
    t.string   "name",               null: false
    t.datetime "started_at",         null: false
    t.string   "transaction_id"
    t.text     "payload"
    t.float    "duration",           null: false
    t.float    "exclusive_duration", null: false
    t.integer  "request_id"
    t.integer  "parent_id"
    t.string   "action",             null: false
    t.string   "category",           null: false
  end

  create_table "transaction_metric_samples", force: :cascade do |t|
    t.integer  "application_id"
    t.integer  "raw_datum_id"
    t.integer  "transaction_id"
    t.integer  "transaction_metric_id"
    t.text     "backtrace"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "transaction_metric_samples", ["application_id"], name: "index_transaction_metric_samples_on_application_id", using: :btree
  add_index "transaction_metric_samples", ["raw_datum_id"], name: "index_transaction_metric_samples_on_raw_datum_id", using: :btree
  add_index "transaction_metric_samples", ["transaction_id"], name: "index_transaction_metric_samples_on_transaction_id", using: :btree
  add_index "transaction_metric_samples", ["transaction_metric_id"], name: "index_transaction_metric_samples_on_transaction_metric_id", using: :btree

  create_table "transaction_metrics", force: :cascade do |t|
    t.integer  "transaction_id"
    t.integer  "raw_datum_id"
    t.integer  "application_id"
    t.string   "name"
    t.datetime "timestamp"
    t.boolean  "error"
    t.float    "duration"
    t.float    "database_duration"
    t.integer  "database_count"
    t.float    "gc_duration"
    t.string   "method"
    t.integer  "code"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "transaction_metrics", ["application_id"], name: "index_transaction_metrics_on_application_id", using: :btree
  add_index "transaction_metrics", ["raw_datum_id"], name: "index_transaction_metrics_on_raw_datum_id", using: :btree
  add_index "transaction_metrics", ["transaction_id"], name: "index_transaction_metrics_on_transaction_id", using: :btree

  create_table "transactions", force: :cascade do |t|
    t.integer  "application_id"
    t.integer  "raw_datum_id"
    t.string   "name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "transactions", ["application_id"], name: "index_transactions_on_application_id", using: :btree
  add_index "transactions", ["raw_datum_id"], name: "index_transactions_on_raw_datum_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_foreign_key "applications", "users"
  add_foreign_key "metrics", "applications"
  add_foreign_key "metrics", "raw_data"
  add_foreign_key "transaction_metric_samples", "applications"
  add_foreign_key "transaction_metric_samples", "raw_data"
  add_foreign_key "transaction_metric_samples", "transaction_metrics"
  add_foreign_key "transaction_metric_samples", "transactions"
  add_foreign_key "transaction_metrics", "applications"
  add_foreign_key "transaction_metrics", "raw_data"
  add_foreign_key "transaction_metrics", "transactions"
  add_foreign_key "transactions", "applications"
  add_foreign_key "transactions", "raw_data"
end
