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

ActiveRecord::Schema.define(version: 20150101213859) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bodies", force: true do |t|
    t.integer  "health"
    t.boolean  "dead"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "max_health"
    t.integer  "world_id"
    t.string   "name"
  end

  create_table "character_actions", force: true do |t|
    t.integer  "character_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "action_id"
    t.string   "target_type"
    t.integer  "target_id"
    t.integer  "stored_vigor"
  end

  create_table "character_body_parts", force: true do |t|
    t.integer "character_id"
    t.string  "body_part_id"
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "progress"
  end

  create_table "character_possessions", force: true do |t|
    t.integer  "character_id"
    t.string   "possession_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "possession_variant_id"
    t.integer  "charges"
  end

  create_table "character_traits", force: true do |t|
    t.integer "character_id"
    t.string  "trait_id"
  end

  create_table "characters", force: true do |t|
    t.string   "name"
    t.integer  "resolve"
    t.integer  "world_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "max_resolve"
    t.integer  "vigor"
    t.integer  "max_vigor"
    t.boolean  "readied"
    t.text     "history"
    t.integer  "nutrition"
  end

  create_table "gesture_components", force: true do |t|
    t.integer  "actor_id"
    t.integer  "owner_id"
    t.string   "target_name"
    t.boolean  "owner_is_target"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gesture_id"
  end

  create_table "interactions", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "activity_id"
  end

  create_table "log_entries", force: true do |t|
    t.integer "log_id"
    t.text    "body"
    t.string  "status"
  end

  create_table "logs", force: true do |t|
    t.string  "owner_type"
    t.integer "owner_id"
  end

  create_table "message_components", force: true do |t|
    t.string  "element_type"
    t.integer "element_id"
    t.integer "message_id"
  end

  create_table "messages", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "possession_variants", force: true do |t|
    t.string "key"
    t.string "possession_id"
    t.string "singular_name"
    t.string "plural_name"
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
    t.boolean  "viewed_by_receiver"
    t.boolean  "viewed_by_sender"
  end

  create_table "speech_components", force: true do |t|
    t.integer "message_component_id"
    t.text    "quote"
    t.integer "actor_id"
  end

  create_table "trade_asked_knowledges", force: true do |t|
    t.integer "trade_id"
    t.integer "duration"
    t.string  "knowledge_id"
  end

  create_table "trade_offered_knowledges", force: true do |t|
    t.integer "trade_id"
    t.integer "duration"
    t.string  "knowledge_id"
  end

  create_table "trade_possessions", force: true do |t|
    t.integer "trade_id"
    t.boolean "offered"
    t.integer "quantity"
    t.string  "possession_id"
    t.integer "possession_variant_id"
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

  create_table "world_situations", force: true do |t|
    t.integer "world_id"
    t.string  "situation_id"
    t.integer "duration"
  end

  create_table "world_visitors", force: true do |t|
    t.integer "world_id"
    t.string  "visitor_id"
    t.string  "target_type"
    t.integer "target_id"
    t.integer "health"
    t.integer "anger"
    t.integer "fear"
    t.boolean "dead",        default: false
  end

  create_table "worlds", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "turn"
    t.datetime "last_turned"
    t.string   "season_id"
  end

  create_table "wounds", force: true do |t|
    t.string   "wound_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "body_id"
  end

end
