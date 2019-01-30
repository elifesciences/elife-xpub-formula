#!/bin/bash
set -e

if [ "$#" -lt 1 ]; then
    echo "Restores the Postgres database from a 'directory'-format dump"
    echo "Usage: ./restore-database.sh FILE"
    echo "Example: ./restore-database.sh /ext/tmp/mydump"
    echo "FILE must use an absolute path (starting with /)"
    exit 1
fi

file="$1"
host="${2:-$PGHOST}"
port="${3:-$PGPORT}"

docker run \
    -e PGHOST="$host" \
    -e PGPORT="$port" \
    -e PGUSER \
    -e PGPASSWORD \
    -v "$file:$file" \
    postgres:10 \
    pg_restore -c -d "$PGDATABASE" -Fd "$file"
