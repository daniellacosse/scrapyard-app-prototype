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

ActiveRecord::Schema.define(version: 20151126033529) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blueprint_holds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blueprint_requirements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blueprints", force: :cascade do |t|
    t.string   "name"
    t.string   "rank"
    t.string   "requirement1"
    t.string   "raw1"
    t.string   "requirement2"
    t.string   "raw2"
    t.string   "requirement3"
    t.string   "raw3"
    t.string   "requirement4"
    t.string   "raw4"
    t.string   "requirement5"
    t.string   "raw5"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "class_options", force: :cascade do |t|
    t.integer  "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "class_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "effects", force: :cascade do |t|
    t.string   "description"
    t.integer  "magnitude"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
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

  create_table "module_effects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "module_holds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "options", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "parts", force: :cascade do |t|
    t.string   "name"
    t.string   "part_type"
    t.string   "rank"
    t.string   "armor"
    t.string   "res"
    t.string   "speed"
    t.string   "effect"
    t.string   "gives_digging"
    t.string   "gives_flying"
    t.string   "has_weapon"
    t.string   "weapon_type"
    t.string   "weapon_dmg"
    t.string   "weapon_elem"
    t.string   "weapon_acc"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "requirements", force: :cascade do |t|
    t.integer  "override_value"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "scrap_classes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scrap_effects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scrap_holds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scrap_options", force: :cascade do |t|
    t.integer  "count",      default: 1
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "scraps", force: :cascade do |t|
    t.string   "name"
    t.string   "scrap_type"
    t.string   "rarity"
    t.string   "raw_value"
    t.string   "event_effect"
    t.boolean  "has_event"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "targets", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "weapon_targets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
