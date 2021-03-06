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

ActiveRecord::Schema.define(version: 20170528065056) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "boards", force: :cascade do |t|
    t.bigint "game_id"
    t.integer "ply", default: 1
    t.boolean "white_to_move", default: true
    t.string "board_data", default: "-4,-2,-3,-5,-6,-3,-2,-4,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,4,2,3,5,6,3,2,4"
    t.string "castling", default: "1111"
    t.string "en_passant", default: "1111"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_boards_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.bigint "black_id"
    t.bigint "white_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["black_id"], name: "index_games_on_black_id"
    t.index ["white_id"], name: "index_games_on_white_id"
  end

  create_table "lobbies", force: :cascade do |t|
    t.bigint "host_id"
    t.bigint "nonhost_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "name"
    t.integer "player_color"
    t.index ["host_id"], name: "index_lobbies_on_host_id"
    t.index ["nonhost_id"], name: "index_lobbies_on_nonhost_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "color"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "human"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "boards", "games"
  add_foreign_key "players", "users"
end
