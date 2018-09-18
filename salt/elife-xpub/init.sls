elife-xpub-repository:
    builder.git_latest:
        - name: git@github.com:elifesciences/elife-xpub-deployment.git
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

elife-xpub-environment-variables-for-configuration:
    file.managed:
        - name: /etc/profile.d/elife-xpub-configuration.sh
        - contents: |
            export ORCID_CLIENT_ID={{ pillar.elife_xpub.orcid.client_id }}
            export ORCID_CLIENT_SECRET={{ pillar.elife_xpub.orcid.client_secret }}
            export PUBSWEET_BASEURL={{ pillar.elife_xpub.pubsweet.base_url }}

elife-xpub-database-startup:
    cmd.run:
        - name: docker-compose up -d postgres
        - user: {{ pillar.elife.deploy_user.username }}
        - cwd: /srv/elife-xpub
        - require:
            - elife-xpub-repository
            - elife-xpub-environment-variables-for-configuration

elife-xpub-database-creation:
    cmd.script:
        - name: salt://elife-xpub/scripts/create-database.sh
        - template: jinja
        - user: {{ pillar.elife.deploy_user.username }}
        - cwd: /srv/elife-xpub
        - require:
            - elife-xpub-database-startup

elife-xpub-docker-compose:
    cmd.run:
        - name: docker-compose up -d --force-recreate
        - user: {{ pillar.elife.deploy_user.username }}
        - cwd: /srv/elife-xpub
        - require:
            - elife-xpub-repository
            - elife-xpub-database-creation

elife-xpub-service-ready:
    cmd.run:
        - name: docker wait xpub_bootstrap_1
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

# frees disk space from old images/containers/volumes/...
elife-xpub-docker-prune:
    cmd.run:
        - name: /usr/local/docker-scripts/docker-prune
        - require:
            - docker-ready
