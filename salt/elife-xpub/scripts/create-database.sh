#!/bin/bash
set -e

if ! docker-compose exec -T postgres psql xpub xpub -c "SELECT 'public.entities'::regclass"; then
    docker-compose run app /bin/bash -c "until echo > /dev/tcp/postgres/5432; do sleep 1; done; npx pubsweet setupdb --username={{ pillar.elife_xpub.database.user }} --password={{ pillar.elife_xpub.database.password }} --email={{ pillar.elife_xpub.database.email }}"
fi

