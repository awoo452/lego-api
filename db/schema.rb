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

ActiveRecord::Schema[8.1].define(version: 2026_03_28_000002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "lego_api_lego_sets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_id"
    t.string "image_url"
    t.string "name"
    t.integer "num_parts"
    t.jsonb "raw_data"
    t.string "theme"
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_lego_api_lego_sets_on_external_id", unique: true
  end

  create_table "lego_api_request_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "duration_ms"
    t.string "http_method", null: false
    t.string "ip"
    t.bigint "lego_set_id"
    t.jsonb "metadata"
    t.string "origin"
    t.jsonb "params"
    t.string "path", null: false
    t.string "referer"
    t.string "request_id"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "index_lego_api_request_logs_on_created_at"
    t.index ["ip"], name: "index_lego_api_request_logs_on_ip"
    t.index ["lego_set_id", "created_at"], name: "index_lego_api_request_logs_on_lego_set_id_and_created_at"
    t.index ["lego_set_id"], name: "index_lego_api_request_logs_on_lego_set_id"
    t.index ["path"], name: "index_lego_api_request_logs_on_path"
    t.index ["request_id"], name: "index_lego_api_request_logs_on_request_id"
  end

  add_foreign_key "lego_api_request_logs", "lego_api_lego_sets", column: "lego_set_id"
end
