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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20151113143805) do

  create_table "applications", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.text     "tables"
    t.string   "time_zone",  :default => "UTC"
  end

  create_table "channels", :force => true do |t|
    t.integer  "application_id"
    t.string   "name"
    t.string   "pigeon_name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "kind"
  end

  create_table "contacts", :force => true do |t|
    t.string   "address"
    t.integer  "application_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.datetime "last_incoming_at"
    t.datetime "last_outgoing_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "task_id"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "execution_loggers", :force => true do |t|
    t.integer  "application_id"
    t.text     "actions"
    t.string   "message_body"
    t.string   "message_from"
    t.integer  "trigger_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "message_to"
    t.string   "trigger_type"
    t.boolean  "no_trigger"
    t.boolean  "with_errors"
    t.string   "trigger_name"
  end

  add_index "execution_loggers", ["application_id"], :name => "index_execution_loggers_on_application_id"
  add_index "execution_loggers", ["trigger_id"], :name => "index_execution_loggers_on_trigger_id"

  create_table "external_service_steps", :force => true do |t|
    t.integer  "external_service_id"
    t.string   "name"
    t.string   "display_name"
    t.string   "icon"
    t.string   "callback_url"
    t.text     "variables"
    t.string   "response_type"
    t.text     "response_variables"
    t.string   "guid"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "external_service_steps", ["external_service_id"], :name => "index_external_service_steps_on_external_service_id"

  create_table "external_services", :force => true do |t|
    t.integer  "application_id"
    t.string   "name"
    t.string   "url"
    t.text     "data"
    t.text     "global_settings"
    t.string   "guid"
    t.string   "base_url"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "external_services", ["application_id"], :name => "index_external_services_on_application_id"

  create_table "external_triggers", :force => true do |t|
    t.integer  "application_id"
    t.string   "name"
    t.text     "actions"
    t.text     "parameters"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "auth_method"
    t.boolean  "enabled",        :default => true
  end

  add_index "external_triggers", ["application_id"], :name => "index_external_triggers_on_application_id"

  create_table "identities", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "instedd_telemetry_counters", :force => true do |t|
    t.integer "period_id"
    t.string  "bucket"
    t.text    "key_attributes"
    t.integer "count",          :default => 0
  end

  create_table "instedd_telemetry_periods", :force => true do |t|
    t.datetime "beginning"
    t.datetime "end"
    t.datetime "stats_sent_at"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "lock_owner"
    t.datetime "lock_expiration"
  end

  create_table "instedd_telemetry_set_occurrences", :force => true do |t|
    t.integer "period_id"
    t.string  "bucket"
    t.text    "key_attributes"
    t.string  "element"
  end

  create_table "instedd_telemetry_settings", :force => true do |t|
    t.string "key"
    t.string "value"
  end

  add_index "instedd_telemetry_settings", ["key"], :name => "index_instedd_telemetry_settings_on_key", :unique => true

  create_table "instedd_telemetry_timespans", :force => true do |t|
    t.string   "bucket"
    t.text     "key_attributes"
    t.datetime "since"
    t.datetime "until"
  end

  create_table "message_triggers", :force => true do |t|
    t.integer  "application_id"
    t.string   "name"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.text     "message"
    t.text     "actions"
    t.boolean  "enabled",        :default => true
  end

  create_table "periodic_tasks", :force => true do |t|
    t.integer  "application_id"
    t.string   "name"
    t.text     "actions"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.text     "schedule"
    t.boolean  "enabled",        :default => true
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "validation_triggers", :force => true do |t|
    t.integer  "application_id"
    t.string   "field_guid"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "from"
    t.string   "invalid_value"
    t.text     "actions"
  end

end
