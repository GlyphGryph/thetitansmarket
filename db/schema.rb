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

ActiveRecord::Schema.define(version: 20140806164411) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "character_actions", force: true do |t|
    t.integer  "character_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "action_id"
    t.string   "target_type"
    t.integer  "target_id"
  end

  create_table "character_conditions", force: true do |t|
    t.integer  "character_id"
    t.string   "condition_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "character_knowledges", force: true do |t|
    t.integer  "character_id"
    t.string   "knowledge_id"
    t.boolean  "known"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "character_possessions", force: true do |t|
    t.integer  "character_id"
    t.string   "possession_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "variant"
    t.string   "contains"
  end

  create_table "characters", force: true do |t|
    t.string   "name"
    t.integer  "hp"
    t.integer  "happy"
    t.integer  "world_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "max_happy"
    t.integer  "max_hp"
    t.integer  "ap"
    t.integer  "max_ap"
    t.boolean  "readied"
    t.text     "history"
  end

  create_table "proposals", force: true do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.string   "status"
    t.integer  "turn"
    t.string   "content_type"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trade_asked_character_possessions", force: true do |t|
    t.integer  "trade_id"
    t.integer  "character_possession_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trade_character_possessions", force: true do |t|
    t.integer  "trade_id"
    t.integer  "character_possession_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trade_offered_character_possessions", force: true do |t|
    t.integer  "trade_id"
    t.integer  "character_possession_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trades", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "world_explorations", force: true do |t|
    t.integer  "world_id"
    t.string   "exploration_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "worlds", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "turn"
    t.datetime "last_turned"
  end

end
