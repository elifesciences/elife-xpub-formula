#!/bin/bash
set -ex

MAX_WAIT=20 # time in seconds
DB_AVAILABLE_COMMAND="nc -z -w ${MAX_WAIT} ${PGHOST} ${PGPORT}"
DC_COMMAND="docker-compose -f docker-compose.yml -f docker-compose.formula.yml"
DB_CREATED_COMMAND="psql -c \"SELECT 'public.entities'::regclass\""

SETUP_ARGS="--username={{ pillar.elife_xpub.database.user }} --password={{ pillar.elife_xpub.database.password }} --email={{ pillar.elife_xpub.database.email }}"

# Run the command to ensure the database is started
$(${DC_COMMAND})

# Wait for the database to come up
if $($(DB_AVAILABLE_COMMAND))
then
    if $(${DC_COMMAND} exec -T postgres /bin/bash -c "${DB_CREATED_COMMAND}")
    then
        $(${DC_COMMAND} run app /bin/bash -c "npx pubsweet setupdb ${SETUP_ARGS}" )
    else
        echo "ERROR: Database was not created: ${PGHOST} ${PGPORT}"
    fi
else
    echo "ERROR: Database not available: ${PGHOST} ${PGPORT}"
fi

