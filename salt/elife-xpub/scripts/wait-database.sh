#!/bin/bash
set -e

DC_COMMAND="docker-compose -f docker-compose.yml -f docker-compose.formula.yml"
DB_CREATED_COMMAND="psql -c \"SELECT 'public.entities'::regclass\""
DB_ENV="-e PGHOST=${PGHOST} -e PGPORT=${PGPORT}"
TIMEOUT="${TIMEOUT:-10}"

# TODO: use -e NAME without [=VALUE]?
${DC_COMMAND} run --rm ${DB_ENV} -e TIMEOUT="${TIMEOUT}" app /bin/bash -c 'timeout "${TIMEOUT}" bash -c "until echo > /dev/tcp/${PGHOST}/${PGPORT} ; do sleep 1; done"'
