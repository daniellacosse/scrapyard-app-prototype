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

ActiveRecord::Schema.define(version: 20150926225705) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blueprint_holds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blueprints", force: :cascade do |t|
    t.string   "requirement_1"
    t.string   "requirement_1_raw_value"
    t.string   "requirement_2"
    t.string   "requirement_2_raw_value"
    t.string   "requirement_3"
    t.string   "requirement_3_raw_value"
    t.string   "requirement_4"
    t.string   "requirement_4_raw_value"
    t.string   "requirement_5"
    t.string   "requirement_5_raw_value"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "game_states", force: :cascade do |t|
    t.integer  "player_id"
    t.integer  "game_id"
    t.integer  "raw"
    t.boolean  "is_my_turn"
    t.integer  "holdable_id"
    t.string   "holdable_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "game_states", ["holdable_type", "holdable_id"], name: "index_game_states_on_holdable_type_and_holdable_id", using: :btree

  create_table "games", force: :cascade do |t|
    t.integer  "guid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "parts", force: :cascade do |t|
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

  create_table "scrap_holds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scraps", force: :cascade do |t|
    t.string   "name"
    t.string   "class"
    t.integer  "raw_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
