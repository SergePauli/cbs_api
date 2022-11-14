# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_11_13_021939) do

  create_table "addresses", force: :cascade do |t|
    t.string "value"
    t.integer "area_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["area_id", "value"], name: "index_addresses_on_area_id_and_value", unique: true
    t.index ["area_id"], name: "index_addresses_on_area_id"
  end

  create_table "areas", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_areas_on_name", unique: true
  end

  create_table "contacts", force: :cascade do |t|
    t.string "value", limit: 250, null: false
    t.string "type", limit: 100, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["value", "type"], name: "index_contacts_on_value_and_type", unique: true
  end

  create_table "departments", force: :cascade do |t|
    t.string "name"
    t.string "def_statuses"
    t.string "def_contract_types"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_departments_on_name", unique: true
  end

  create_table "namings", force: :cascade do |t|
    t.string "surname"
    t.string "patrname"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["surname", "name", "patrname"], name: "index_namings_on_surname_and_name_and_patrname", unique: true
  end

  create_table "people", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "person_addresses", force: :cascade do |t|
    t.integer "person_id", null: false
    t.integer "address_id", null: false
    t.integer "priority", default: 1, null: false
    t.boolean "used", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["address_id"], name: "index_person_addresses_on_address_id"
    t.index ["person_id", "address_id"], name: "index_person_addresses_on_person_id_and_address_id", unique: true
    t.index ["person_id"], name: "index_person_addresses_on_person_id"
    t.index ["priority"], name: "index_person_addresses_on_priority"
  end

  create_table "person_contacts", force: :cascade do |t|
    t.integer "person_id", null: false
    t.integer "contact_id", null: false
    t.integer "priority", default: 1, null: false
    t.boolean "used", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contact_id"], name: "index_person_contacts_on_contact_id"
    t.index ["person_id", "contact_id"], name: "index_person_contacts_on_person_id_and_contact_id", unique: true
    t.index ["person_id"], name: "index_person_contacts_on_person_id"
    t.index ["priority"], name: "index_person_contacts_on_priority"
  end

  create_table "person_names", force: :cascade do |t|
    t.integer "person_id", null: false
    t.integer "naming_id", null: false
    t.boolean "used", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["naming_id"], name: "index_person_names_on_naming_id"
    t.index ["person_id", "naming_id"], name: "index_person_names_on_person_id_and_naming_id", unique: true
    t.index ["person_id"], name: "index_person_names_on_person_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "password_digest"
    t.integer "person_id", null: false
    t.string "role", default: "user", null: false
    t.datetime "last_login"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["person_id"], name: "index_users_on_person_id"
  end

  add_foreign_key "addresses", "areas"
  add_foreign_key "person_addresses", "addresses"
  add_foreign_key "person_addresses", "people"
  add_foreign_key "person_contacts", "contacts"
  add_foreign_key "person_contacts", "people"
  add_foreign_key "person_names", "namings"
  add_foreign_key "person_names", "people"
  add_foreign_key "users", "people"
end
