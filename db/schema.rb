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

ActiveRecord::Schema.define(version: 20180214220308) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar"
    t.string   "email"
  end

  create_table "items", force: :cascade do |t|
    t.string   "name"
    t.integer  "week_id"
    t.integer  "participant_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "participants", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "middle_name"
    t.string   "club"
    t.string   "grade_level"
    t.string   "email_address"
    t.string   "phone_number"
    t.string   "library_card"
    t.boolean  "got_packet"
    t.boolean  "got_final_prize"
    t.string   "zip_coed"
    t.boolean  "inactive"
    t.string   "home_library"
    t.string   "school"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "reports", force: :cascade do |t|
    t.integer  "week_id"
    t.integer  "participant_id"
    t.string   "day_of_week"
    t.integer  "minutes"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "weeks", force: :cascade do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
