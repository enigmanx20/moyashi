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

ActiveRecord::Schema.define(version: 20140228055301) do

  create_table "labels", force: true do |t|
    t.string   "name"
    t.string   "white_list"
    t.boolean  "uniqueness"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "label_order"
  end

  add_index "labels", ["project_id"], name: "index_labels_on_project_id"

  create_table "projects", force: true do |t|
    t.string   "name"
    t.text     "comment"
    t.float    "m_z_start"
    t.float    "m_z_end"
    t.float    "m_z_interval"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

end
