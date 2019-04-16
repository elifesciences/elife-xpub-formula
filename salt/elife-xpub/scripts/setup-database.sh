#!/bin/bash
set -e

dc="docker-compose -f docker-compose.yml -f docker-compose.formula.yml"
db_env="-e PGHOST=${PGHOST} -e PGPORT=${PGPORT} -e PGUSER=${PGUSER} -e PGDATABASE=${PGDATABASE} -e PGPASSWORD=${PGPASSWORD}"
recreate="dropdb ${PGDATABASE} && createdb ${PGDATABASE}"

# Removing setting up a user (via clobber) in PubSweet as at the moment this is no longer necessary
# This may be re-instated after the work to upgrade to the latest PubSweet version.
# Ref: elifesciences/elife-xpub/issues/1920
#
# SETUP_ARGS="--username={{ pillar.elife_xpub.database.user }} --password={{ pillar.elife_xpub.database.password }} --email={{ pillar.elife_xpub.database.email }}"

if [ ! -z "${DROP}" ]; then
    ${dc} run --rm ${db_env} postgres /bin/bash -c "${recreate}"
fi

echo Always run the migrate to ensure the database has the correct schema
${dc} run --rm app /bin/bash -c "npx pubsweet migrate"
