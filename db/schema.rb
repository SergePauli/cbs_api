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

ActiveRecord::Schema.define(version: 2023_01_12_110004) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "value"
    t.bigint "area_id", null: false
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

  create_table "audits", force: :cascade do |t|
    t.string "auditable_type"
    t.bigint "auditable_id"
    t.integer "action", limit: 2, null: false
    t.string "auditable_field"
    t.string "detail"
    t.string "before"
    t.string "after"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["action"], name: "index_audits_on_action"
    t.index ["auditable_type", "auditable_id"], name: "index_audits_on_auditable"
    t.index ["user_id"], name: "index_audits_on_user_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "value", limit: 250, null: false
    t.string "type", limit: 100, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["value", "type"], name: "index_contacts_on_value_and_type", unique: true
  end

  create_table "contragent_addresses", force: :cascade do |t|
    t.bigint "contragent_id", null: false
    t.bigint "address_id", null: false
    t.integer "priority", default: 1, null: false
    t.boolean "used", default: true, null: false
    t.integer "kind", limit: 2, default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["address_id"], name: "index_contragent_addresses_on_address_id"
    t.index ["contragent_id", "address_id", "kind"], name: "by_contr_addr_ids", unique: true
    t.index ["contragent_id"], name: "index_contragent_addresses_on_contragent_id"
    t.index ["kind"], name: "index_contragent_addresses_on_kind"
    t.index ["priority"], name: "index_contragent_addresses_on_priority"
  end

  create_table "contragent_contacts", force: :cascade do |t|
    t.bigint "contragent_id", null: false
    t.bigint "contact_id", null: false
    t.integer "priority", default: 1, null: false
    t.boolean "used", default: true, null: false
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contact_id"], name: "index_contragent_contacts_on_contact_id"
    t.index ["contragent_id", "contact_id"], name: "index_contragent_contacts_on_contragent_id_and_contact_id", unique: true
    t.index ["contragent_id"], name: "index_contragent_contacts_on_contragent_id"
  end

  create_table "contragent_organizations", force: :cascade do |t|
    t.bigint "contragent_id", null: false
    t.bigint "organization_id", null: false
    t.integer "priority", default: 1, null: false
    t.boolean "used", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contragent_id", "organization_id"], name: "by_contr_org_ids", unique: true
    t.index ["contragent_id"], name: "index_contragent_organizations_on_contragent_id"
    t.index ["organization_id"], name: "index_contragent_organizations_on_organization_id"
    t.index ["used", "organization_id"], name: "by_used_org_ids", unique: true
  end

  create_table "contragents", force: :cascade do |t|
    t.uuid "obj_uuid", default: -> { "gen_random_uuid()" }, null: false
    t.string "description"
    t.string "bank_name"
    t.string "bank_bik", limit: 10
    t.string "bank_account", limit: 30
    t.string "bank_cor_account", limit: 30
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "departments", force: :cascade do |t|
    t.string "name"
    t.string "def_statuses"
    t.string "def_contracts_types"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_departments_on_name", unique: true
  end

  create_table "employees", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.bigint "contragent_id", null: false
    t.bigint "position_id"
    t.integer "priority", default: 1, null: false
    t.boolean "used", default: true, null: false
    t.string "description"
    t.uuid "obj_uuid", default: -> { "gen_random_uuid()" }, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contragent_id", "person_id", "position_id"], name: "index_employees_on_contragent_id_and_person_id_and_position_id", unique: true
    t.index ["contragent_id"], name: "index_employees_on_contragent_id"
    t.index ["person_id"], name: "index_employees_on_person_id"
    t.index ["position_id"], name: "index_employees_on_position_id"
  end

  create_table "namings", force: :cascade do |t|
    t.string "surname"
    t.string "patrname"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["surname", "name", "patrname"], name: "index_namings_on_surname_and_name_and_patrname", unique: true
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.string "full_name"
    t.string "inn", limit: 10
    t.string "kpp", limit: 9
    t.string "ogrn", limit: 13
    t.string "okpo", limit: 10
    t.string "oktmo", limit: 11
    t.string "okved", limit: 10
    t.string "okogu", limit: 9
    t.string "okfc", limit: 3
    t.string "okopf", limit: 8
    t.bigint "ownership_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["full_name"], name: "index_organizations_on_full_name"
    t.index ["inn", "kpp"], name: "index_organizations_on_inn_and_kpp", unique: true
    t.index ["ownership_id"], name: "index_organizations_on_ownership_id"
  end

  create_table "ownerships", force: :cascade do |t|
    t.string "name", null: false
    t.string "full_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_ownerships_on_name", unique: true
  end

  create_table "people", force: :cascade do |t|
    t.string "inn", limit: 12
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "person_addresses", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.bigint "address_id", null: false
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
    t.bigint "person_id", null: false
    t.bigint "contact_id", null: false
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
    t.bigint "person_id", null: false
    t.bigint "naming_id", null: false
    t.boolean "used", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["naming_id"], name: "index_person_names_on_naming_id"
    t.index ["person_id", "naming_id"], name: "index_person_names_on_person_id_and_naming_id", unique: true
    t.index ["person_id"], name: "index_person_names_on_person_id"
  end

  create_table "positions", force: :cascade do |t|
    t.string "name"
    t.string "def_statuses"
    t.string "def_contracts_types"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_positions_on_name", unique: true
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "position_id", null: false
    t.bigint "department_id"
    t.integer "priority", default: 1, null: false
    t.boolean "used", default: true, null: false
    t.string "statuses"
    t.string "contracts_types"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["department_id"], name: "index_profiles_on_department_id"
    t.index ["position_id"], name: "index_profiles_on_position_id"
    t.index ["priority"], name: "index_profiles_on_priority"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "password_digest"
    t.bigint "person_id", null: false
    t.string "role", default: "user", null: false
    t.string "activation_link", null: false
    t.boolean "activated", default: false, null: false
    t.datetime "last_login"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["person_id"], name: "index_users_on_person_id"
  end

  add_foreign_key "addresses", "areas"
  add_foreign_key "contragent_addresses", "addresses"
  add_foreign_key "contragent_addresses", "contragents"
  add_foreign_key "contragent_contacts", "contacts"
  add_foreign_key "contragent_contacts", "contragents"
  add_foreign_key "contragent_organizations", "contragents"
  add_foreign_key "contragent_organizations", "organizations"
  add_foreign_key "employees", "contragents"
  add_foreign_key "employees", "people"
  add_foreign_key "employees", "positions"
  add_foreign_key "organizations", "ownerships"
  add_foreign_key "person_addresses", "addresses"
  add_foreign_key "person_addresses", "people"
  add_foreign_key "person_contacts", "contacts"
  add_foreign_key "person_contacts", "people"
  add_foreign_key "person_names", "namings"
  add_foreign_key "person_names", "people"
  add_foreign_key "profiles", "departments"
  add_foreign_key "profiles", "positions"
  add_foreign_key "profiles", "users"
  add_foreign_key "users", "people"
end
