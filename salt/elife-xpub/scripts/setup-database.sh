#!/bin/bash
set -e

if ! docker-compose -f docker-compose.yml -f docker-compose.formula.yml exec -T postgres /bin/bash -c "until echo > /dev/tcp/postgres/5432; do sleep 1; done; psql -c \"SELECT 'public.entities'::regclass\""; then
    docker-compose  -f docker-compose.yml -f docker-compose.formula.yml run app /bin/bash -c "until echo > /dev/tcp/postgres/5432; do sleep 1; done; npx pubsweet setupdb --username={{ pillar.elife_xpub.database.user }} --password={{ pillar.elife_xpub.database.password }} --email={{ pillar.elife_xpub.database.email }}"
fi

