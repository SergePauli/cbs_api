#!/usr/bin/env bash
set -euo pipefail

APP_CONTAINER="${1:-${APP_CONTAINER:-cbs_api}}"
RAILS_ENV="${RAILS_ENV:-production}"

ORDER_MIGRATION="20230221071810"
ISECURITY_TOOL_MIGRATION="20230221065429"
STAGE_ORDER_MIGRATION="20230221071809"

ORDER_MIGRATION_FILE="db/migrate/${ORDER_MIGRATION}_create_orders.rb"
ISECURITY_TOOL_MIGRATION_FILE="db/migrate/${ISECURITY_TOOL_MIGRATION}_create_isecurity_tools.rb"
STAGE_ORDER_MIGRATION_FILE="db/migrate/${STAGE_ORDER_MIGRATION}_create_stage_orders.rb"

run_in_container() {
  docker exec -e RAILS_ENV="${RAILS_ENV}" "${APP_CONTAINER}" "$@"
}

if ! docker inspect "${APP_CONTAINER}" >/dev/null 2>&1; then
  echo "Docker container '${APP_CONTAINER}' was not found." >&2
  echo "Usage: RAILS_ENV=production $0 <container_name_or_id>" >&2
  exit 1
fi

if [ "$(docker inspect -f '{{.State.Running}}' "${APP_CONTAINER}")" != "true" ]; then
  echo "Docker container '${APP_CONTAINER}' is not running." >&2
  exit 1
fi

for migration_file in \
  "${ORDER_MIGRATION_FILE}" \
  "${ISECURITY_TOOL_MIGRATION_FILE}" \
  "${STAGE_ORDER_MIGRATION_FILE}"
do
  if ! run_in_container test -f "${migration_file}"; then
    echo "Migration file '${migration_file}' was not found inside container '${APP_CONTAINER}'." >&2
    echo "Rebuild/recreate the project container or mount the current project directory into it before running this script." >&2
    exit 1
  fi
done

echo "Recreating order tables in container '${APP_CONTAINER}' with RAILS_ENV='${RAILS_ENV}'..."

read -r -d '' RESET_TABLES_RUBY <<'RUBY' || true
connection = ActiveRecord::Base.connection

tables = %i[stage_orders orders isecurity_tools]
migration_versions = %w[
  20230221071809
  20230221071810
  20230221065429 
]

tables.each do |table_name|
  connection.execute("DROP TABLE IF EXISTS #{connection.quote_table_name(table_name)} CASCADE")
  puts "Dropped #{table_name} if it existed"
end

quoted_versions = migration_versions.map { |version| connection.quote(version) }.join(", ")
connection.execute("DELETE FROM schema_migrations WHERE version IN (#{quoted_versions})")
puts "Deleted migration versions: #{migration_versions.join(', ')}"
RUBY

run_in_container rails runner "${RESET_TABLES_RUBY}"

run_in_container rails db:migrate:up VERSION="${ORDER_MIGRATION}"
run_in_container rails db:migrate:up VERSION="${ISECURITY_TOOL_MIGRATION}"
run_in_container rails db:migrate:up VERSION="${STAGE_ORDER_MIGRATION}"

echo "Done. Recreated orders, isecurity_tools, and stage_orders."
