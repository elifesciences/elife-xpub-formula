#!/bin/bash
set -e

if [ "$#" -lt 1 ]; then
    echo "Dumps a Postgres database into a 'directory'-format dump"
    echo "Usage: ./dump-database.sh FILE [HOST] [PORT]"
    echo "Example: ./dump-database.sh /ext/tmp/mydump elife-xpub-staging-restore-test.cxyopn44uqbl.us-east-1.rds.amazonaws.com 5432"
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
    -e PGDATABASE \
    -v "$file:$file" \
    postgres:10 \
    pg_dump -Fd -f "$file"
