#!/bin/bash
set -ex

DC_COMMAND="docker-compose -f docker-compose.yml -f docker-compose.formula.yml"
DB_CREATED_COMMAND="psql -c \"SELECT 'public.entities'::regclass\""

SETUP_ARGS="--username={{ pillar.elife_xpub.database.user }} --password={{ pillar.elife_xpub.database.password }} --email={{ pillar.elife_xpub.database.email }}"

if ! $(${DC_COMMAND} run postgres /bin/bash -c "${DB_CREATED_COMMAND}")
then
    $(${DC_COMMAND} run app /bin/bash -c "npx pubsweet setupdb ${SETUP_ARGS}" )
else
    echo "Database is already present at ${PGHOST}:${PGPORT}"
fi

