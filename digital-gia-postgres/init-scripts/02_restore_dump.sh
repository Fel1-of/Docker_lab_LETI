#!/bin/sh
set -e

PGHOST=${PGHOST:-localhost}
PGUSER=${POSTGRES_USER:-postgres}
PGPASSWORD=${POSTGRES_PASSWORD}
PGDATABASE=${POSTGRES_DB:-gia}

DUMP_FILE=${DUMP_FILE:-dump.dump}

pg_restore --verbose -U "$PGUSER" -Fc -c --if-exists -d "$PGDATABASE" "/dump/$DUMP_FILE"