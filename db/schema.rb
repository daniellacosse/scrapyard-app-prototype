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

ActiveRecord::Schema.define(version: 20160119021850) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blueprint_holds", force: :cascade do |t|
    t.integer  "blueprint_id"
    t.integer  "game_state_id"
    t.integer  "game_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "blueprint_requirements", force: :cascade do |t|
    t.integer  "blueprint_id"
    t.integer  "requirement_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "blueprints", force: :cascade do |t|
    t.string   "rank"
    t.integer  "scrapper_module_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "class_options", force: :cascade do |t|
    t.integer  "class_type_id"
    t.integer  "option_id"
    t.integer  "count",         default: 1
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "class_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "game_states", force: :cascade do |t|
    t.integer  "player_id"
    t.integer  "player_number"
    t.integer  "game_id"
    t.integer  "raw",           default: 0
    t.boolean  "is_ready"
    t.boolean  "is_my_turn"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "games", force: :cascade do |t|
    t.integer  "guid"
    t.boolean  "has_started", default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "game_state_id"
    t.string   "text"
    t.boolean  "is_viewed",     default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "module_holds", force: :cascade do |t|
    t.integer  "scrapper_module_id"
    t.integer  "game_state_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "options", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "players", force: :cascade do |t|
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
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

  add_index "players", ["email"], name: "index_players_on_email", unique: true, using: :btree
  add_index "players", ["reset_password_token"], name: "index_players_on_reset_password_token", unique: true, using: :btree

  create_table "requirement_options", force: :cascade do |t|
    t.integer  "requirement_id"
    t.integer  "option_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "requirements", force: :cascade do |t|
    t.integer  "override_value"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "scrap_classes", force: :cascade do |t|
    t.integer  "scrap_id"
    t.integer  "class_type_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "scrap_holds", force: :cascade do |t|
    t.integer  "scrap_id"
    t.integer  "game_state_id"
    t.integer  "value"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "scrap_options", force: :cascade do |t|
    t.integer  "count",      default: 1
    t.integer  "scrap_id"
    t.integer  "option_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "scrapper_modules", force: :cascade do |t|
    t.integer  "blueprint_id"
    t.integer  "armor"
    t.string   "damage_type"
    t.integer  "damage"
    t.integer  "mobility"
    t.string   "name"
    t.integer  "range"
    t.integer  "resilience"
    t.integer  "spread"
    t.string   "text"
    t.string   "module_class"
    t.integer  "class_id"
    t.integer  "weight"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "scraps", force: :cascade do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trades", force: :cascade do |t|
    t.boolean  "is_agreed",                            default: false
    t.integer  "game_state_id"
    t.integer  "proposing_player_state_id"
    t.integer  "raw_cost"
    t.integer  "proposing_player_raw_cost"
    t.integer  "scrap_hold_cost"
    t.integer  "proposing_player_scrap_hold_cost"
    t.integer  "blueprint_hold_cost"
    t.integer  "proposing_player_blueprint_hold_cost"
    t.integer  "module_hold_cost"
    t.integer  "proposing_player_module_hold_cost"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
  end

end
