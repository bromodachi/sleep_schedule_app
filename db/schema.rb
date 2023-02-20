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

ActiveRecord::Schema[7.0].define(version: 2023_02_19_020952) do
  create_table "followers", force: :cascade do |t|
    t.integer "follower_id"
    t.integer "followee_id"
    t.boolean "active"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["follower_id", "followee_id"], name: "index_followers_on_follower_id_and_followee_id", unique: true
  end

  create_table "sleep_schedules", force: :cascade do |t|
    t.integer "user_id"
    t.datetime "slept_at"
    t.datetime "woke_up_at"
    t.integer "total_slept_seconds"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["total_slept_seconds"], name: "index_sleep_schedules_on_total_slept_seconds"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }
  end

end
