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

ActiveRecord::Schema.define(version: 20171101185138) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "timescaledb"

  create_table "applications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "license_key"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "organization_id"
  end

  add_index "applications", ["name", "user_id"], name: "index_applications_on_name_and_user_id", unique: true, using: :btree
  add_index "applications", ["organization_id"], name: "index_applications_on_organization_id", using: :btree
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
    t.string   "span_id"
    t.string   "statement"
    t.datetime "timestamp"
    t.float    "duration"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "organization_id"
  end

  add_index "database_calls", ["application_id"], name: "index_database_calls_on_application_id", using: :btree
  add_index "database_calls", ["database_type_id"], name: "index_database_calls_on_database_type_id", using: :btree
  add_index "database_calls", ["host_id"], name: "index_database_calls_on_host_id", using: :btree
  add_index "database_calls", ["layer_id"], name: "index_database_calls_on_layer_id", using: :btree
  add_index "database_calls", ["organization_id"], name: "index_database_calls_on_organization_id", using: :btree
  add_index "database_calls", ["span_id"], name: "index_database_calls_on_span_id", using: :btree
  add_index "database_calls", ["timestamp"], name: "index_database_calls_on_timestamp", using: :btree

  create_table "database_types", force: :cascade do |t|
    t.integer  "application_id"
    t.string   "name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "organization_id"
  end

  add_index "database_types", ["application_id"], name: "index_database_types_on_application_id", using: :btree
  add_index "database_types", ["organization_id"], name: "index_database_types_on_organization_id", using: :btree

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
    t.integer  "organization_id"
    t.string   "span_id"
  end

  add_index "error_data", ["application_id"], name: "index_error_data_on_application_id", using: :btree
  add_index "error_data", ["error_message_id"], name: "index_error_data_on_error_message_id", using: :btree
  add_index "error_data", ["host_id"], name: "index_error_data_on_host_id", using: :btree
  add_index "error_data", ["organization_id"], name: "index_error_data_on_organization_id", using: :btree

  create_table "error_messages", force: :cascade do |t|
    t.integer  "application_id"
    t.string   "fingerprint"
    t.string   "error_class"
    t.string   "error_message"
    t.datetime "last_error_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "organization_id"
  end

  add_index "error_messages", ["application_id"], name: "index_error_messages_on_application_id", using: :btree
  add_index "error_messages", ["organization_id"], name: "index_error_messages_on_organization_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "type"
    t.integer  "application_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "title"
    t.string   "description"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "organization_id"
  end

  add_index "events", ["application_id"], name: "index_events_on_application_id", using: :btree
  add_index "events", ["organization_id"], name: "index_events_on_organization_id", using: :btree

  create_table "hosts", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "organization_id"
  end

  add_index "hosts", ["organization_id"], name: "index_hosts_on_organization_id", using: :btree

  create_table "layers", force: :cascade do |t|
    t.integer  "application_id"
    t.string   "name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "organization_id"
  end

  add_index "layers", ["application_id"], name: "index_layers_on_application_id", using: :btree
  add_index "layers", ["name", "application_id"], name: "index_layers_on_name_and_application_id", unique: true, using: :btree
  add_index "layers", ["organization_id"], name: "index_layers_on_organization_id", using: :btree

  create_table "log_entries", force: :cascade do |t|
    t.string   "span_id"
    t.string   "event"
    t.datetime "timestamp"
    t.text     "fields"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "log_entries", ["span_id"], name: "index_log_entries_on_span_id", using: :btree

  create_table "metric_data", force: :cascade do |t|
    t.integer  "host_id"
    t.integer  "metric_id"
    t.datetime "timestamp"
    t.float    "value"
    t.jsonb    "tags",      default: {}
  end

  add_index "metric_data", ["host_id"], name: "index_metric_data_on_host_id", using: :btree
  add_index "metric_data", ["metric_id"], name: "index_metric_data_on_metric_id", using: :btree
  add_index "metric_data", ["tags"], name: "idx_metric_data_tags", using: :gin

  create_table "metrics", force: :cascade do |t|
    t.integer  "application_id"
    t.integer  "host_id"
    t.string   "name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "organization_id"
  end

  add_index "metrics", ["application_id"], name: "index_metrics_on_application_id", using: :btree
  add_index "metrics", ["host_id"], name: "index_metrics_on_host_id", using: :btree
  add_index "metrics", ["organization_id"], name: "index_metrics_on_organization_id", using: :btree

  create_table "new_spans", id: false, force: :cascade do |t|
    t.integer  "id",                 default: "nextval('spans_id_seq'::regclass)", null: false
    t.integer  "application_id"
    t.integer  "host_id"
    t.string   "grouping_id"
    t.string   "grouping_type"
    t.integer  "layer_id"
    t.integer  "trace_id"
    t.string   "span_type",          default: "web"
    t.string   "name"
    t.datetime "timestamp",                                                        null: false
    t.float    "duration"
    t.float    "exclusive_duration"
    t.string   "trace_key"
    t.string   "uuid"
    t.jsonb    "payload"
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.integer  "organization_id"
  end

  add_index "new_spans", ["application_id"], name: "new_spans_application_id_idx", using: :btree
  add_index "new_spans", ["grouping_type", "grouping_id"], name: "new_spans_grouping_type_grouping_id_idx", using: :btree
  add_index "new_spans", ["host_id"], name: "new_spans_host_id_idx", using: :btree
  add_index "new_spans", ["layer_id"], name: "new_spans_layer_id_idx", using: :btree
  add_index "new_spans", ["organization_id"], name: "new_spans_organization_id_idx", using: :btree
  add_index "new_spans", ["payload"], name: "new_spans_payload_idx", using: :gin
  add_index "new_spans", ["timestamp"], name: "new_spans_timestamp_idx", using: :btree
  add_index "new_spans", ["trace_id"], name: "new_spans_trace_id_idx", using: :btree

  create_table "new_traces", id: false, force: :cascade do |t|
    t.integer  "id",              default: "nextval('traces_id_seq'::regclass)", null: false
    t.integer  "application_id"
    t.integer  "host_id"
    t.string   "trace_key"
    t.datetime "timestamp",                                                      null: false
    t.float    "duration"
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.integer  "organization_id"
  end

  add_index "new_traces", ["application_id"], name: "new_traces_application_id_idx", using: :btree
  add_index "new_traces", ["host_id"], name: "new_traces_host_id_idx", using: :btree
  add_index "new_traces", ["organization_id"], name: "new_traces_organization_id_idx", using: :btree
  add_index "new_traces", ["timestamp", "trace_key", "application_id"], name: "new_traces_trace_key_application_id_idx", using: :btree
  add_index "new_traces", ["timestamp"], name: "new_traces_timestamp_idx", using: :btree

  create_table "organization_users", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "organization_users", ["organization_id"], name: "index_organization_users_on_organization_id", using: :btree
  add_index "organization_users", ["user_id"], name: "index_organization_users_on_user_id", using: :btree

  create_table "organizations", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "license_key"
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "organizations", ["user_id"], name: "index_organizations_on_user_id", using: :btree

  create_table "spans", force: :cascade do |t|
    t.integer  "application_id"
    t.integer  "host_id"
    t.integer  "layer_id"
    t.string   "trace_id"
    t.string   "name"
    t.datetime "timestamp"
    t.float    "duration"
    t.float    "exclusive_duration"
    t.string   "uuid"
    t.jsonb    "payload"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "organization_id"
    t.string   "parent_id"
    t.string   "operation_name"
  end

  add_index "spans", ["application_id"], name: "index_spans_on_application_id", using: :btree
  add_index "spans", ["host_id"], name: "index_spans_on_host_id", using: :btree
  add_index "spans", ["layer_id"], name: "index_spans_on_layer_id", using: :btree
  add_index "spans", ["organization_id"], name: "index_spans_on_organization_id", using: :btree
  add_index "spans", ["payload"], name: "idx_spans_payload", using: :gin
  add_index "spans", ["timestamp"], name: "index_spans_on_timestamp", using: :btree
  add_index "spans", ["trace_id"], name: "index_spans_on_trace_id", using: :btree

  create_table "traces", force: :cascade do |t|
    t.integer  "application_id"
    t.integer  "host_id"
    t.string   "trace_key"
    t.datetime "timestamp"
    t.float    "duration"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "organization_id"
  end

  add_index "traces", ["application_id"], name: "index_traces_on_application_id", using: :btree
  add_index "traces", ["host_id"], name: "index_traces_on_host_id", using: :btree
  add_index "traces", ["organization_id"], name: "index_traces_on_organization_id", using: :btree
  add_index "traces", ["timestamp"], name: "index_traces_on_timestamp", using: :btree
  add_index "traces", ["trace_key", "application_id"], name: "index_traces_on_trace_key_and_application_id", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "license_key"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

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
  add_foreign_key "layers", "applications"
  add_foreign_key "metric_data", "hosts"
  add_foreign_key "metric_data", "metrics"
  add_foreign_key "metrics", "applications"
  add_foreign_key "metrics", "hosts"
  add_foreign_key "organization_users", "organizations"
  add_foreign_key "organization_users", "users"
  add_foreign_key "organizations", "users"
  add_foreign_key "spans", "applications"
  add_foreign_key "spans", "hosts"
  add_foreign_key "spans", "layers"
  add_foreign_key "traces", "applications"
  add_foreign_key "traces", "hosts"
end
