#!/usr/bin/env bash
set -euo pipefail

APP_CONTAINER="${1:-${APP_CONTAINER:-cbs_api}}"
RAILS_ENV="${RAILS_ENV:-production}"

CONTRACT_RESPONSIBLES_MIGRATION="20260823000000"
CONTRACT_RESPONSIBLES_MIGRATION_FILE="db/migrate/${CONTRACT_RESPONSIBLES_MIGRATION}_create_contract_responsibles.rb"

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

if ! run_in_container test -f "${CONTRACT_RESPONSIBLES_MIGRATION_FILE}"; then
  echo "Migration file '${CONTRACT_RESPONSIBLES_MIGRATION_FILE}' was not found inside container '${APP_CONTAINER}'." >&2
  echo "Rebuild/recreate the project container or mount the current project directory before running this script." >&2
  exit 1
fi

echo "Recreating contract_responsibles in container '${APP_CONTAINER}' with RAILS_ENV='${RAILS_ENV}'..."

read -r -d '' RESET_CONTRACT_RESPONSIBLES_RUBY <<'RUBY' || true
connection = ActiveRecord::Base.connection
table_name = :contract_responsibles
migration_version = "20260823000000"

connection.execute("DROP TABLE IF EXISTS #{connection.quote_table_name(table_name)} CASCADE")
puts "Dropped #{table_name} if it existed"

connection.execute(
  "DELETE FROM schema_migrations WHERE version = #{connection.quote(migration_version)}"
)
puts "Deleted migration version: #{migration_version}"
RUBY

run_in_container rails runner "${RESET_CONTRACT_RESPONSIBLES_RUBY}"
run_in_container rails db:migrate:up VERSION="${CONTRACT_RESPONSIBLES_MIGRATION}"

echo "Done. Recreated contract_responsibles."
