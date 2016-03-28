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

ActiveRecord::Schema.define(version: 20150811041917) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "benchmark_result_types", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "unit",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "benchmark_result_types", ["name", "unit"], name: "index_benchmark_result_types_on_name_and_unit", unique: true, using: :btree

  create_table "benchmark_runs", force: :cascade do |t|
    t.hstore   "result",                                  null: false
    t.text     "environment",                             null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "initiator_id"
    t.string   "initiator_type"
    t.integer  "benchmark_type_id",        default: 0,    null: false
    t.integer  "benchmark_result_type_id",                null: false
    t.boolean  "validity",                 default: true
  end

  add_index "benchmark_runs", ["benchmark_type_id"], name: "index_benchmark_runs_on_benchmark_type_id", using: :btree
  add_index "benchmark_runs", ["initiator_type", "initiator_id"], name: "index_benchmark_runs_on_initiator_type_and_initiator_id", using: :btree

  create_table "benchmark_types", force: :cascade do |t|
    t.string   "category",   null: false
    t.string   "script_url", null: false
    t.integer  "repo_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "digest"
  end

  add_index "benchmark_types", ["repo_id", "category", "script_url"], name: "index_benchmark_types_on_repo_id_and_category_and_script_url", unique: true, using: :btree
  add_index "benchmark_types", ["repo_id"], name: "index_benchmark_types_on_repo_id", using: :btree

  create_table "commits", force: :cascade do |t|
    t.string   "sha1",       null: false
    t.string   "url",        null: false
    t.text     "message",    null: false
    t.integer  "repo_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "commits", ["repo_id"], name: "index_commits_on_repo_id", using: :btree
  add_index "commits", ["sha1", "repo_id"], name: "index_commits_on_sha1_and_repo_id", unique: true, using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "url",        null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "organizations", ["name"], name: "index_organizations_on_name", unique: true, using: :btree

  create_table "releases", force: :cascade do |t|
    t.integer  "repo_id",    null: false
    t.string   "version",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "releases", ["repo_id"], name: "index_releases_on_repo_id", using: :btree

  create_table "repos", force: :cascade do |t|
    t.string   "name",            null: false
    t.string   "url",             null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "organization_id", null: false
  end

  add_index "repos", ["name", "organization_id"], name: "index_repos_on_name_and_organization_id", unique: true, using: :btree
  add_index "repos", ["organization_id"], name: "index_repos_on_organization_id", using: :btree
  add_index "repos", ["url"], name: "index_repos_on_url", unique: true, using: :btree

end
