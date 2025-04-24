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

ActiveRecord::Schema[8.0].define(version: 2025_04_23_235310) do
  create_table "time_entries", force: :cascade do |t|
    t.integer "user_id", null: false
    t.date "date"
    t.time "time"
    t.string "entry_type"
    t.string "status"
    t.text "observation"
    t.boolean "signature"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "time_sheet_id", null: false
    t.index ["date"], name: "index_time_entries_on_date"
    t.index ["status"], name: "index_time_entries_on_status"
    t.index ["time_sheet_id"], name: "index_time_entries_on_time_sheet_id"
    t.index ["user_id", "date"], name: "index_time_entries_on_user_id_and_date"
    t.index ["user_id"], name: "index_time_entries_on_user_id"
  end

  create_table "time_sheets", force: :cascade do |t|
    t.integer "user_id", null: false
    t.date "date"
    t.string "status"
    t.decimal "total_hours"
    t.string "approval_status"
    t.integer "approved_by"
    t.datetime "approved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "signature"
    t.text "justification"
    t.string "justification_status"
    t.index ["approval_status"], name: "index_time_sheets_on_approval_status"
    t.index ["approved_by"], name: "index_time_sheets_on_approved_by"
    t.index ["date"], name: "index_time_sheets_on_date"
    t.index ["justification_status"], name: "index_time_sheets_on_justification_status"
    t.index ["status"], name: "index_time_sheets_on_status"
    t.index ["user_id", "date"], name: "index_time_sheets_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_time_sheets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "department"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "employee_id"
    t.string "position"
    t.date "start_date"
    t.string "status"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "time_entries", "time_sheets"
  add_foreign_key "time_entries", "users"
  add_foreign_key "time_sheets", "users"
end
