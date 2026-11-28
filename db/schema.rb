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

ActiveRecord::Schema[8.1].define(version: 2026_11_28_025041) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "collection_items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "title_id", null: false
    t.string "condition", default: "complete", null: false
    t.text "notes"
    t.date "acquired_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title_id"], name: "index_collection_items_on_title_id"
    t.index ["user_id", "title_id"], name: "index_collection_items_on_user_id_and_title_id", unique: true
    t.index ["user_id"], name: "index_collection_items_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "titles", force: :cascade do |t|
    t.string "name", null: false
    t.string "publisher"
    t.string "developer"
    t.integer "release_year"
    t.string "genre"
    t.string "platform"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "box_width_mm"
    t.integer "box_height_mm"
    t.integer "box_depth_mm"
    t.virtual "searchable", type: :tsvector, as: "(((setweight(to_tsvector('simple'::regconfig, (COALESCE(name, ''::character varying))::text), 'A'::\"char\") || setweight(to_tsvector('simple'::regconfig, (((COALESCE(publisher, ''::character varying))::text || ' '::text) || (COALESCE(developer, ''::character varying))::text)), 'B'::\"char\")) || setweight(to_tsvector('simple'::regconfig, (((COALESCE(genre, ''::character varying))::text || ' '::text) || (COALESCE(platform, ''::character varying))::text)), 'C'::\"char\")) || setweight(to_tsvector('simple'::regconfig, COALESCE(description, ''::text)), 'D'::\"char\"))", stored: true
    t.index ["genre"], name: "index_titles_on_genre"
    t.index ["name"], name: "index_titles_on_name"
    t.index ["platform"], name: "index_titles_on_platform"
    t.index ["publisher"], name: "index_titles_on_publisher"
    t.index ["release_year"], name: "index_titles_on_release_year"
    t.index ["searchable"], name: "index_titles_on_searchable", using: :gin
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.string "username", null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "collection_items", "titles"
  add_foreign_key "collection_items", "users"
  add_foreign_key "sessions", "users"
end
