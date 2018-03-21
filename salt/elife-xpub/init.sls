# TODO: deprecated, remove when applied everywhere
elife-xpub-systemd:
    cmd.run:
        - name: |
            systemctl stop xpub
            rm -rf /srv/xpub

    file.absent:
        - name: /lib/systemd/system/xpub.service

elife-xpub-repository:
    builder.git_latest:
        - name: git@github.com:elifesciences/elife-xpub.git
        - identity: {{ pillar.elife.projects_builder.key or '' }}
        - rev: {{ salt['elife.rev']() }}
        - branch: {{ salt['elife.branch']() }}
        - target: /srv/elife-xpub/
        - force_fetch: True
        - force_checkout: True
        - force_reset: True

    file.directory:
        - name: /srv/elife-xpub
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group
        - require:
            - builder: elife-xpub-repository

elife-xpub-database-setup:
    cmd.run:
        - name: docker-compose run app /bin/bash -c "until echo > /dev/tcp/postgres/5432; do sleep 1; done; npx pubsweet setupdb --username={{ pillar.elife_xpub.database.user }} --password={{ pillar.elife_xpub.database.password }} --email={{ pillar.elife_xpub.database.email }} --clobber"

elife-xpub-docker-compose:
    cmd.run:
        - name: docker-compose up -d --force-recreate
        - user: {{ pillar.elife.deploy_user.username }}
        - cwd: /srv/elife-xpub
        - require:
            - elife-xpub-repository
            - elife-xpub-database-setup

elife-xpub-service-ready:
    cmd.run:
        - name: wait_for_port 3000
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - elife-xpub-docker-compose

elife-xpub-nginx-vhost:
    file.managed:
        - name: /etc/nginx/sites-enabled/xpub.conf
        - source: salt://elife-xpub/config/etc-nginx-sites-enabled-xpub.conf
        - template: jinja
        - require:
            - nginx-config
            - elife-xpub-service-ready
        - listen_in:
            - service: nginx-server-service
