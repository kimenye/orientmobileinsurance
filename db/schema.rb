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

ActiveRecord::Schema.define(:version => 20131018094436) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "is_admin",               :default => false
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "agents", :force => true do |t|
    t.string   "town"
    t.string   "brand"
    t.string   "outlet"
    t.string   "location"
    t.string   "code"
    t.string   "email"
    t.string   "phone_number"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "outlet_name"
  end

  create_table "brands", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "town_name"
    t.string   "brand_1"
    t.string   "brand_2"
    t.string   "brand_3"
    t.string   "brand_4"
  end

  create_table "claims", :force => true do |t|
    t.string   "claim_no"
    t.datetime "incident_date"
    t.integer  "policy_id"
    t.string   "claim_type"
    t.string   "contact_number"
    t.string   "contact_email"
    t.string   "incident_description"
    t.string   "status"
    t.string   "status_description"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "nearest_town"
    t.integer  "step"
    t.string   "visible_damage"
    t.string   "type_of_liquid"
    t.string   "incident_location"
    t.string   "q_1"
    t.string   "q_2"
    t.string   "q_3"
    t.string   "q_4"
    t.string   "q_5"
    t.integer  "agent_id"
    t.boolean  "police_abstract"
    t.boolean  "receipt"
    t.boolean  "original_id"
    t.boolean  "copy_id"
    t.boolean  "blocking_request"
    t.string   "dealer_description"
    t.boolean  "dealer_can_fix"
    t.decimal  "dealer_cost_estimate"
    t.datetime "time_duration"
    t.boolean  "damaged_device"
    t.boolean  "authorized"
    t.decimal  "replacement_limit"
    t.text     "decline_reason"
    t.integer  "days_to_fix"
    t.decimal  "repair_limit"
    t.string   "authorization_type"
  end

  add_index "claims", ["agent_id"], :name => "index_claims_on_agent_id"
  add_index "claims", ["policy_id"], :name => "index_claims_on_policy_id"

  create_table "customers", :force => true do |t|
    t.string   "name"
    t.string   "id_passport"
    t.string   "email"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "phone_number"
    t.string   "alternate_phone_number"
    t.boolean  "lead",                   :default => true
  end

  create_table "devices", :force => true do |t|
    t.string   "vendor"
    t.string   "model"
    t.string   "marketing_name"
    t.decimal  "catalog_price"
    t.decimal  "wholesale_price"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.decimal  "fd_insured_value"
    t.decimal  "fd_replacement_value"
    t.decimal  "fd_koil_invoice_value"
    t.decimal  "yop_insured_value"
    t.decimal  "yop_replacement_value"
    t.decimal  "yop_fd_koil_invoice_value"
    t.decimal  "prev_insured_value"
    t.decimal  "prev_replacement_value"
    t.decimal  "prev_fd_koil_invoice_value"
    t.string   "device_type"
    t.string   "stock_code"
    t.boolean  "active",                     :default => true
    t.integer  "version",                    :default => 0
  end

  create_table "enquiries", :force => true do |t|
    t.string   "phone_number"
    t.string   "text"
    t.string   "date_of_enquiry"
    t.string   "source"
    t.string   "sales_agent_code"
    t.string   "url"
    t.string   "hashed_phone_number"
    t.string   "detected_device_id"
    t.string   "undetected_device_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "year_of_purchase"
    t.integer  "agent_id"
    t.string   "hashed_timestamp"
    t.string   "model"
    t.string   "vendor"
    t.string   "marketing_name"
    t.boolean  "detected"
    t.string   "user_agent"
    t.string   "id_type"
    t.string   "customer_id"
  end

  create_table "insured_devices", :force => true do |t|
    t.integer  "customer_id"
    t.integer  "device_id"
    t.string   "imei"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "yop"
    t.string   "phone_number"
  end

  add_index "insured_devices", ["customer_id"], :name => "index_insured_devices_on_customer_id"
  add_index "insured_devices", ["device_id"], :name => "index_insured_devices_on_device_id"

  create_table "messages", :force => true do |t|
    t.string   "phone_number"
    t.string   "text"
    t.integer  "message_type"
    t.string   "status"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "payments", :force => true do |t|
    t.integer  "policy_id"
    t.string   "reference"
    t.decimal  "amount"
    t.string   "status"
    t.string   "method"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "payments", ["policy_id"], :name => "index_payments_on_policy_id"

  create_table "policies", :force => true do |t|
    t.integer  "quote_id"
    t.string   "status"
    t.string   "policy_number"
    t.datetime "start_date"
    t.datetime "expiry"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "policies", ["quote_id"], :name => "index_policies_on_quote_id"

  create_table "quotes", :force => true do |t|
    t.integer  "insured_device_id"
    t.decimal  "annual_premium"
    t.decimal  "monthly_premium"
    t.string   "account_name"
    t.string   "premium_type"
    t.datetime "expiry_date"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.decimal  "insured_value"
    t.integer  "agent_id"
  end

  add_index "quotes", ["agent_id"], :name => "index_quotes_on_agent_id"
  add_index "quotes", ["insured_device_id"], :name => "index_quotes_on_insured_device_id"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sms", :force => true do |t|
    t.string   "to"
    t.string   "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "request"
    t.text     "response"
    t.string   "receipt_id"
    t.boolean  "delivered"
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
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "name"
    t.string   "user_type"
    t.integer  "agent_id"
    t.string   "username"
  end

  add_index "users", ["agent_id"], :name => "index_users_on_agent_id"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

end
