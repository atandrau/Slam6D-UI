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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110320155136) do

  create_table "icps", :force => true do |t|
    t.string   "name"
    t.string   "parameters",           :default => "-a 9 -r 10 -d 500 -i 1000"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "first_scan_id"
    t.integer  "second_scan_id"
    t.string   "first_scan_position",  :default => "0 0 0"
    t.string   "first_scan_rotation",  :default => "0 0 0"
    t.string   "second_scan_position", :default => "0 0 0"
    t.string   "second_scan_rotation", :default => "0 0 0"
  end

  create_table "icps_pointclouds", :id => false, :force => true do |t|
    t.integer "icp_id"
    t.integer "pointcloud_id"
  end

  create_table "matchings", :force => true do |t|
    t.string   "name"
    t.integer  "pointcloud_id"
    t.integer  "best_model_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pointclouds", :force => true do |t|
    t.string   "label"
    t.string   "path"
    t.string   "source"
    t.string   "format"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sketchupmodel_id"
    t.string   "transf_matrix"
  end

  create_table "sketchupmodels", :force => true do |t|
    t.string   "name"
    t.string   "google_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
