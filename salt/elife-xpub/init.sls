{% set docker_compose = 'docker-compose -f docker-compose.yml -f docker-compose.formula.yml' %}

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

elife-xpub-logs:
    file.directory:
        - name: /srv/elife-xpub/var/logs/
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - makedirs: True
        - dir_mode: 775
        - require:
            - elife-xpub-repository

elife-xpub-environment-variables-for-configuration:
    file.managed:
        - name: /etc/profile.d/elife-xpub-configuration.sh
        - contents: |
            export ORCID_CLIENT_ID={{ pillar.elife_xpub.orcid.client_id }}
            export ORCID_CLIENT_SECRET={{ pillar.elife_xpub.orcid.client_secret }}
            export PUBSWEET_BASEURL={{ pillar.elife_xpub.pubsweet.base_url }}
            export S3_BUCKET={{ pillar.elife_xpub.s3.bucket }}
            export NODE_CONFIG_ENV={{ pillar.elife_xpub.deployment_target }}

elife-xpub-environment-variables-for-database-credentials:
    file.managed:
        - name: /etc/profile.d/elife-xpub-database-credentials.sh
        - contents: |
            {% if salt['elife.cfg']('cfn.outputs.RDSHost') %}
            # remote RDS server
            export PGHOST={{ salt['elife.cfg']('cfn.outputs.RDSHost') }}
            export PGPORT={{ salt['elife.cfg']('cfn.outputs.RDSPort') }}
            export PGDATABASE={{ salt['elife.cfg']('project.rds_dbname') }}
            export PGUSER={{ salt['elife.cfg']('project.rds_username') }}
            export PGPASSWORD={{ salt['elife.cfg']('project.rds_password') }}
            {% else %}
            # local container
            export PGHOST=postgres
            export PGPORT=5432
            export PGDATABASE=
            export PGUSER=xpub
            export PGPASSWORD=
            {% endif %}

{% if salt['elife.cfg']('cfn.outputs.RDSHost') %}
{% else %}
elife-xpub-database-startup:
    cmd.run:
        - name: {{ docker_compose }} up -d postgres
        - user: {{ pillar.elife.deploy_user.username }}
        - cwd: /srv/elife-xpub
        - require:
            - elife-xpub-repository
            - elife-xpub-environment-variables-for-configuration
            - elife-xpub-environment-variables-for-database-credentials

elife-xpub-database-setup:
    cmd.script:
        - name: salt://elife-xpub/scripts/setup-database.sh
        - template: jinja
        - user: {{ pillar.elife.deploy_user.username }}
        - cwd: /srv/elife-xpub
        - require:
            - elife-xpub-database-startup
{% endif %}

elife-xpub-docker-compose:
    cmd.run:
        - name: {{ docker_compose }} up -d --force-recreate
        - user: {{ pillar.elife.deploy_user.username }}
        - cwd: /srv/elife-xpub
        - require:
            - elife-xpub-repository
            - elife-xpub-database-setup

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
