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

ActiveRecord::Schema.define(version: 2023_02_22_092603) do

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
    t.bigint "auditable_id", comment: "объект (место изменений)"
    t.integer "action", limit: 2, null: false, comment: "вид изменений"
    t.string "auditable_field", comment: "что изменили"
    t.string "detail", comment: "пояснение"
    t.string "before", comment: "данные до изменения"
    t.string "after", comment: "данные после изменения"
    t.bigint "user_id", comment: "ссылка на пользователя (кто изменил)"
    t.bigint "person_id", comment: "персональные данные пользователя, на момент комментирования"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["action"], name: "index_audits_on_action"
    t.index ["auditable_type", "auditable_id"], name: "index_audits_on_auditable"
    t.index ["person_id"], name: "index_audits_on_person_id"
    t.index ["user_id"], name: "index_audits_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.string "commentable_type"
    t.bigint "commentable_id", comment: "что комментируем"
    t.string "content", null: false, comment: "содержание комментария"
    t.bigint "profile_id", comment: "профиль пользователя с должностью и отделом"
    t.bigint "person_id", comment: "данные пользователя, на момент комментирования"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
    t.index ["person_id"], name: "index_comments_on_person_id"
    t.index ["profile_id"], name: "index_comments_on_profile_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "value", limit: 250, null: false
    t.string "type", limit: 100, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["value", "type"], name: "index_contacts_on_value_and_type", unique: true
  end

  create_table "contract_numbers", force: :cascade do |t|
    t.bigint "contract_id", null: false, comment: "контракт"
    t.string "number", null: false, comment: "полный номер контракта"
    t.string "LinkFileProtocol", comment: "ссылка на скан"
    t.string "LinkFileScan", comment: "ссылка на скан"
    t.string "LinkFileDoc", comment: "ссылка на текст"
    t.string "LinkFileZip", comment: "ссылка на архив"
    t.boolean "used", default: true, null: false, comment: "признак отображения как номера контракта"
    t.integer "additional_number", comment: "номер доп.соглашения"
    t.boolean "is_present", comment: "признак наличия подписаного оригинала контракта"
    t.uuid "list_key", null: false, comment: "служебный ключ списка, для логгирования"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contract_id"], name: "index_contract_numbers_on_contract_id"
    t.index ["number"], name: "index_contract_numbers_on_number"
  end

  create_table "contracts", force: :cascade do |t|
    t.bigint "contragent_id", null: false, comment: "контрагент"
    t.bigint "task_kind_id", null: false, comment: "тип контракта"
    t.bigint "status_id", null: false, comment: "статус"
    t.integer "order", default: 1, null: false, comment: "сквозной номер, относительно года и типа"
    t.integer "year", null: false, comment: "год контракта"
    t.string "code", limit: 2, null: false, comment: "код типа контракта"
    t.boolean "governmental", default: false, null: false, comment: "госконтракт?"
    t.date "signed_at", comment: "дата контракта (подписания)"
    t.integer "deadline_kind", comment: "вид срока"
    t.float "cost", comment: "сумма контракта"
    t.float "tax", comment: "НДС"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contragent_id"], name: "index_contracts_on_contragent_id"
    t.index ["status_id"], name: "index_contracts_on_status_id"
    t.index ["task_kind_id"], name: "index_contracts_on_task_kind_id"
  end

  create_table "contragent_addresses", force: :cascade do |t|
    t.bigint "contragent_id", null: false
    t.bigint "address_id", null: false
    t.integer "priority", default: 1, null: false
    t.boolean "used", default: true, null: false
    t.integer "kind", limit: 2, default: 0, null: false
    t.uuid "list_key", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["address_id"], name: "index_contragent_addresses_on_address_id"
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
    t.uuid "list_key", null: false
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
    t.uuid "list_key", null: false
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
    t.uuid "list_key", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contragent_id", "person_id", "position_id"], name: "index_employees_on_contragent_id_and_person_id_and_position_id", unique: true
    t.index ["contragent_id"], name: "index_employees_on_contragent_id"
    t.index ["person_id"], name: "index_employees_on_person_id"
    t.index ["position_id"], name: "index_employees_on_position_id"
  end

  create_table "isecurity_tools", force: :cascade do |t|
    t.string "name", null: false, comment: "наименование"
    t.integer "unit", null: false, comment: "ед. измерения"
    t.integer "priority", default: 0, null: false, comment: "порядок в списке"
    t.boolean "used", default: true, null: false, comment: "признак использования"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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

  create_table "payments", force: :cascade do |t|
    t.bigint "stage_id", null: false, comment: "этап"
    t.date "payment_at", comment: "дата платежа"
    t.float "amount", comment: "сумма"
    t.string "description", comment: "примечание"
    t.uuid "list_key", null: false, comment: "служебный ключ списка, для логгирования"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["stage_id"], name: "index_payments_on_stage_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "inn", limit: 12
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "performers", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.bigint "department_id", null: false
    t.bigint "position_id"
    t.integer "priority", default: 1, null: false
    t.boolean "used", default: true, null: false
    t.string "description"
    t.uuid "list_key", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["department_id", "person_id", "position_id"], name: "index_performers_on_department_id_and_person_id_and_position_id", unique: true
    t.index ["department_id"], name: "index_performers_on_department_id"
    t.index ["person_id"], name: "index_performers_on_person_id"
    t.index ["position_id"], name: "index_performers_on_position_id"
  end

  create_table "person_addresses", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.bigint "address_id", null: false
    t.integer "priority", default: 1, null: false
    t.boolean "used", default: true, null: false
    t.uuid "list_key", null: false
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
    t.uuid "list_key", null: false
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
    t.uuid "list_key", null: false
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
    t.uuid "list_key", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["department_id"], name: "index_profiles_on_department_id"
    t.index ["position_id"], name: "index_profiles_on_position_id"
    t.index ["priority"], name: "index_profiles_on_priority"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "stage_orders", force: :cascade do |t|
    t.bigint "stage_id", null: false, comment: "этап"
    t.bigint "isecurity_tool_id", null: false, comment: "СЗИ, товар"
    t.bigint "status_id", null: false, comment: "статус поставки"
    t.bigint "contragent_id", null: false, comment: "поставщик"
    t.float "amount", comment: "колличество"
    t.date "requested_at", comment: "дата запроса счета"
    t.string "order_number", comment: "счет на поставку"
    t.date "ordered_at", comment: "дата счета"
    t.date "payment_at", comment: "дата оплаты счета"
    t.date "received_at", comment: "дата прихода"
    t.string "description", comment: "примечание"
    t.uuid "list_key", null: false, comment: "служебный ключ списка, для логгирования"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contragent_id"], name: "index_stage_orders_on_contragent_id"
    t.index ["isecurity_tool_id"], name: "index_stage_orders_on_isecurity_tool_id"
    t.index ["stage_id"], name: "index_stage_orders_on_stage_id"
    t.index ["status_id"], name: "index_stage_orders_on_status_id"
  end

  create_table "stage_performers", force: :cascade do |t|
    t.bigint "stage_id", null: false, comment: "этап"
    t.bigint "performer_id", null: false, comment: "исполнитель"
    t.uuid "list_key", null: false, comment: "служебный ключ списка, для логгирования"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["performer_id", "stage_id"], name: "index_stage_performers_on_performer_id_and_stage_id", unique: true
    t.index ["performer_id"], name: "index_stage_performers_on_performer_id"
    t.index ["stage_id"], name: "index_stage_performers_on_stage_id"
  end

  create_table "stages", force: :cascade do |t|
    t.bigint "contract_id", null: false, comment: "контракт"
    t.bigint "task_kind_id", null: false, comment: "тип работы"
    t.bigint "status_id", null: false, comment: "статус"
    t.float "cost", comment: "сумма этапа"
    t.date "deadline", comment: "срок выполнения"
    t.date "funded_at", comment: "дата бухгалтерского закрытия"
    t.date "completed_at", comment: "дата закрытия"
    t.integer "deadline_kind", comment: "вид срока"
    t.integer "duration", comment: "время выполнения в днях"
    t.date "sended_at", comment: "дата отправки документации"
    t.boolean "is_sended", comment: "документы высланы"
    t.date "ride_out_at", comment: "дата выезда"
    t.boolean "is_ride_out", comment: "признак выезда к контрагенту"
    t.uuid "list_key", null: false, comment: "служебный ключ списка, для логгирования"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contract_id"], name: "index_stages_on_contract_id"
    t.index ["status_id"], name: "index_stages_on_status_id"
    t.index ["task_kind_id"], name: "index_stages_on_task_kind_id"
  end

  create_table "statuses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "task_kinds", force: :cascade do |t|
    t.string "name"
    t.string "code", limit: 2
    t.string "description"
    t.float "cost"
    t.integer "duration"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_task_kinds_on_code"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "stage_id", null: false, comment: "этап"
    t.bigint "task_kind_id", null: false, comment: "тип работы, задачи"
    t.uuid "list_key", null: false, comment: "служебный ключ списка, для логгирования"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["stage_id"], name: "index_tasks_on_stage_id"
    t.index ["task_kind_id"], name: "index_tasks_on_task_kind_id"
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
  add_foreign_key "contract_numbers", "contracts"
  add_foreign_key "contracts", "contragents"
  add_foreign_key "contracts", "statuses"
  add_foreign_key "contracts", "task_kinds"
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
  add_foreign_key "payments", "stages"
  add_foreign_key "performers", "departments"
  add_foreign_key "performers", "people"
  add_foreign_key "performers", "positions"
  add_foreign_key "person_addresses", "addresses"
  add_foreign_key "person_addresses", "people"
  add_foreign_key "person_contacts", "contacts"
  add_foreign_key "person_contacts", "people"
  add_foreign_key "person_names", "namings"
  add_foreign_key "person_names", "people"
  add_foreign_key "profiles", "departments"
  add_foreign_key "profiles", "positions"
  add_foreign_key "profiles", "users"
  add_foreign_key "stage_orders", "contragents"
  add_foreign_key "stage_orders", "isecurity_tools"
  add_foreign_key "stage_orders", "stages"
  add_foreign_key "stage_orders", "statuses"
  add_foreign_key "stage_performers", "performers"
  add_foreign_key "stage_performers", "stages"
  add_foreign_key "stages", "contracts"
  add_foreign_key "stages", "statuses"
  add_foreign_key "stages", "task_kinds"
  add_foreign_key "tasks", "stages"
  add_foreign_key "tasks", "task_kinds"
  add_foreign_key "users", "people"
end
