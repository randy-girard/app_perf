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

ActiveRecord::Schema.define(version: 20170108135011) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "analytic_event_data", force: :cascade do |t|
    t.integer  "application_id"
    t.integer  "host_id"
    t.datetime "timestamp"
    t.string   "name"
    t.float    "value"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "analytic_event_data", ["application_id"], name: "index_analytic_event_data_on_application_id", using: :btree
  add_index "analytic_event_data", ["host_id"], name: "index_analytic_event_data_on_host_id", using: :btree

  create_table "applications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "license_key"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.decimal  "data_retention_hours", precision: 6, scale: 1
  end

  add_index "applications", ["name", "user_id"], name: "index_applications_on_name_and_user_id", unique: true, using: :btree
  add_index "applications", ["user_id"], name: "index_applications_on_user_id", using: :btree

  create_table "backtraces", force: :cascade do |t|
    t.string   "backtraceable_id"
    t.string   "backtraceable_type"
    t.text     "backtrace"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "backtraces", ["backtraceable_type", "backtraceable_id"], name: "index_backtraces_on_backtraceable_type_and_backtraceable_id", using: :btree

  create_table "database_calls", force: :cascade do |t|
    t.integer  "application_id"
    t.integer  "host_id"
    t.integer  "database_type_id"
    t.integer  "layer_id"
    t.string   "uuid"
    t.string   "statement"
    t.datetime "timestamp"
    t.float    "duration"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "database_calls", ["application_id"], name: "index_database_calls_on_application_id", using: :btree
  add_index "database_calls", ["database_type_id"], name: "index_database_calls_on_database_type_id", using: :btree
  add_index "database_calls", ["host_id"], name: "index_database_calls_on_host_id", using: :btree
  add_index "database_calls", ["layer_id"], name: "index_database_calls_on_layer_id", using: :btree
  add_index "database_calls", ["uuid"], name: "index_database_calls_on_uuid", using: :btree

  create_table "database_types", force: :cascade do |t|
    t.integer  "application_id"
    t.string   "name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "database_types", ["application_id"], name: "index_database_types_on_application_id", using: :btree

  create_table "error_data", force: :cascade do |t|
    t.integer  "application_id"
    t.integer  "host_id"
    t.integer  "error_message_id"
    t.string   "transaction_id"
    t.string   "message"
    t.text     "backtrace"
    t.datetime "timestamp"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.text     "source"
  end

  add_index "error_data", ["application_id"], name: "index_error_data_on_application_id", using: :btree
  add_index "error_data", ["error_message_id"], name: "index_error_data_on_error_message_id", using: :btree
  add_index "error_data", ["host_id"], name: "index_error_data_on_host_id", using: :btree

  create_table "error_messages", force: :cascade do |t|
    t.integer  "application_id"
    t.string   "fingerprint"
    t.string   "error_class"
    t.string   "error_message"
    t.datetime "last_error_at"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "error_messages", ["application_id"], name: "index_error_messages_on_application_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "type"
    t.integer  "application_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "title"
    t.string   "description"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "events", ["application_id"], name: "index_events_on_application_id", using: :btree

  create_table "hosts", force: :cascade do |t|
    t.integer  "application_id"
    t.string   "name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "hosts", ["application_id"], name: "index_hosts_on_application_id", using: :btree
  add_index "hosts", ["name", "application_id"], name: "index_hosts_on_name_and_application_id", unique: true, using: :btree

  create_table "layers", force: :cascade do |t|
    t.integer  "application_id"
    t.string   "name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "layers", ["application_id"], name: "index_layers_on_application_id", using: :btree
  add_index "layers", ["name", "application_id"], name: "index_layers_on_name_and_application_id", unique: true, using: :btree

  create_table "traces", force: :cascade do |t|
    t.integer  "application_id"
    t.integer  "host_id"
    t.string   "trace_key"
    t.datetime "timestamp"
    t.float    "duration"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "traces", ["application_id"], name: "index_traces_on_application_id", using: :btree
  add_index "traces", ["host_id"], name: "index_traces_on_host_id", using: :btree
  add_index "traces", ["trace_key", "application_id"], name: "index_traces_on_trace_key_and_application_id", unique: true, using: :btree

  create_table "transaction_data", force: :cascade do |t|
    t.integer  "application_id"
    t.integer  "host_id"
    t.integer  "transaction_endpoint_id"
    t.integer  "layer_id"
    t.datetime "timestamp"
    t.integer  "call_count"
    t.float    "duration"
    t.float    "avg"
    t.float    "min"
    t.float    "max"
    t.float    "sum_sqr"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "transaction_data", ["application_id"], name: "index_transaction_data_on_application_id", using: :btree
  add_index "transaction_data", ["host_id"], name: "index_transaction_data_on_host_id", using: :btree
  add_index "transaction_data", ["layer_id"], name: "index_transaction_data_on_layer_id", using: :btree
  add_index "transaction_data", ["transaction_endpoint_id"], name: "index_transaction_data_on_transaction_endpoint_id", using: :btree

  create_table "transaction_endpoints", force: :cascade do |t|
    t.integer  "application_id"
    t.string   "name"
    t.string   "controller"
    t.string   "action"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "transaction_endpoints", ["application_id"], name: "index_transaction_endpoints_on_application_id", using: :btree

  create_table "transaction_sample_data", force: :cascade do |t|
    t.integer  "application_id"
    t.integer  "host_id"
    t.string   "grouping_id"
    t.string   "grouping_type"
    t.integer  "layer_id"
    t.integer  "transaction_endpoint_id"
    t.integer  "trace_id"
    t.string   "sample_type",             default: "web"
    t.string   "name"
    t.datetime "timestamp"
    t.text     "payload"
    t.float    "duration"
    t.float    "exclusive_duration"
    t.string   "trace_key"
    t.string   "request_id"
    t.string   "parent_id"
    t.string   "category"
    t.string   "url"
    t.string   "domain"
    t.string   "controller"
    t.string   "action"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "transaction_sample_data", ["application_id"], name: "index_transaction_sample_data_on_application_id", using: :btree
  add_index "transaction_sample_data", ["grouping_type", "grouping_id"], name: "index_transaction_sample_data_on_grouping_type_and_grouping_id", using: :btree
  add_index "transaction_sample_data", ["host_id"], name: "index_transaction_sample_data_on_host_id", using: :btree
  add_index "transaction_sample_data", ["layer_id"], name: "index_transaction_sample_data_on_layer_id", using: :btree
  add_index "transaction_sample_data", ["trace_id"], name: "index_transaction_sample_data_on_trace_id", using: :btree
  add_index "transaction_sample_data", ["transaction_endpoint_id"], name: "index_transaction_sample_data_on_transaction_endpoint_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "license_key"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_foreign_key "analytic_event_data", "applications"
  add_foreign_key "analytic_event_data", "hosts"
  add_foreign_key "applications", "users"
  add_foreign_key "database_calls", "applications"
  add_foreign_key "database_calls", "database_types"
  add_foreign_key "database_calls", "hosts"
  add_foreign_key "database_calls", "layers"
  add_foreign_key "database_types", "applications"
  add_foreign_key "error_data", "applications"
  add_foreign_key "error_data", "error_messages"
  add_foreign_key "error_data", "hosts"
  add_foreign_key "error_messages", "applications"
  add_foreign_key "events", "applications"
  add_foreign_key "hosts", "applications"
  add_foreign_key "layers", "applications"
  add_foreign_key "traces", "applications"
  add_foreign_key "traces", "hosts"
  add_foreign_key "transaction_data", "applications"
  add_foreign_key "transaction_data", "hosts"
  add_foreign_key "transaction_data", "layers"
  add_foreign_key "transaction_data", "transaction_endpoints"
  add_foreign_key "transaction_endpoints", "applications"
  add_foreign_key "transaction_sample_data", "applications"
  add_foreign_key "transaction_sample_data", "hosts"
  add_foreign_key "transaction_sample_data", "layers"
  add_foreign_key "transaction_sample_data", "traces"
  add_foreign_key "transaction_sample_data", "transaction_endpoints"
end
