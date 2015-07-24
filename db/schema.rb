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

ActiveRecord::Schema.define(version: 20150415032038) do

  create_table "sieve_filter_settings", force: :cascade do |t|
    t.datetime "begin_at",                         null: false
    t.datetime "end_at",                           null: false
    t.boolean  "forward",            limit: 1,     null: false
    t.string   "forwarding_address", limit: 255
    t.boolean  "vacation",           limit: 1,     null: false
    t.string   "subject",            limit: 255
    t.text     "body",               limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reply_options",      limit: 255
    t.integer  "user_id",            limit: 4
  end

  add_index "sieve_filter_settings", ["user_id"], name: "index_sieve_filter_settings_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",      limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["id", "email"], name: "index_users_on_id_and_email", unique: true, using: :btree

end
