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

ActiveRecord::Schema.define(version: 20150730100002) do
   create_table :events do |t|
      t.string :event_id, :null => false
      t.datetime :created_at, :null => false
      t.datetime :updated_at, :null => false
      t.string :summary, :null => false
      t.text :description, :null => false
      t.text :location, :null => false
      t.string :creator, :null => false
      t.string :category, :null => false
      t.datetime :start, :null => false
      t.datetime :end, :null => false
      t.string :link
   end

   create_table :categories do |t|
      t.string :name, :null => false
      t.text :calendar_id, :null => false
      t.boolean :addible, :null => false
   end
end
