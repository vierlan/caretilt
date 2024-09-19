# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_09_19_200048) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "blog_posts", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.string "description"
    t.boolean "draft", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "booking_enquiries", force: :cascade do |t|
    t.string "contact_name"
    t.string "contact_phone"
    t.string "service_user_name"
    t.text "message"
    t.bigint "user_id", null: false
    t.bigint "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_booking_enquiries_on_room_id"
    t.index ["user_id"], name: "index_booking_enquiries_on_user_id"
  end

  create_table "care_homes", force: :cascade do |t|
    t.string "name"
    t.jsonb "address"
    t.string "phone_number"
    t.string "main_contact"
    t.text "short_description"
    t.text "long_description"
    t.string "type_of_home"
    t.string "types_of_client_group", default: [], array: true
    t.bigint "company_id", null: false
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "website"
    t.string "address1", null: false
    t.string "address2", null: false
    t.string "city", null: false
    t.string "postcode", null: false
    t.string "county"
    t.string "country"
    t.string "local_authority_name"
    t.index ["company_id"], name: "index_care_homes_on_company_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.integer "companies_house_id"
    t.string "registered_address"
    t.string "phone_number"
    t.string "billing_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "registration_pin", default: "2285", null: false
    t.string "super_pin", default: "7223", null: false
    t.string "stripe_customer_id"
    t.string "email"
    t.string "contact_name"
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "postcode"
    t.string "country"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "local_authorities", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "local_authority_data", force: :cascade do |t|
    t.string "local_authority_code"
    t.string "official_name"
    t.string "nice_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mail_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "mailer"
    t.string "to"
    t.text "subject"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_mail_logs_on_user_id"
  end

  create_table "packages", force: :cascade do |t|
    t.string "name"
    t.integer "validity"
    t.integer "credits"
    t.integer "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name"
    t.integer "core_fee_level"
    t.integer "core_hours_of_care"
    t.boolean "additional_fees_associated"
    t.jsonb "other_data"
    t.string "single_double"
    t.boolean "ensuite"
    t.bigint "care_home_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "vacant", default: false
    t.index ["care_home_id"], name: "index_rooms_on_care_home_id"
  end

  create_table "script_tags", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.boolean "enabled", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "receipt_number"
    t.date "expires_on"
    t.integer "credits_left"
    t.string "credit_log", default: [], array: true
    t.date "next_payment_date"
    t.boolean "active"
    t.date "subscribed_on"
    t.integer "number_of_payments"
    t.bigint "company_id", null: false
    t.bigint "package_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_subscriptions_on_company_id"
    t.index ["package_id"], name: "index_subscriptions_on_package_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.string "stripe_customer_id"
    t.boolean "paying_customer", default: false
    t.string "stripe_subscription_id"
    t.string "first_name"
    t.string "last_name"
    t.integer "role", default: 0
    t.float "latitude"
    t.float "longitude"
    t.bigint "company_id"
    t.bigint "local_authority_id"
    t.bigint "care_home_id"
    t.integer "status", default: 0, null: false
    t.index ["care_home_id"], name: "index_users_on_care_home_id"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["local_authority_id"], name: "index_users_on_local_authority_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "booking_enquiries", "rooms"
  add_foreign_key "booking_enquiries", "users"
  add_foreign_key "care_homes", "companies"
  add_foreign_key "rooms", "care_homes"
  add_foreign_key "subscriptions", "companies"
  add_foreign_key "subscriptions", "packages"
  add_foreign_key "users", "care_homes"
  add_foreign_key "users", "companies"
  add_foreign_key "users", "local_authorities"
end
