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

xpub-repository:
    builder.git_latest:
        - name: https://gitlab.coko.foundation/yld/xpub.git 
        #- name: git@github.com:elifesciences/xpub.git
        #- identity: {{ pillar.elife.projects_builder.key or '' }}
        - rev: master
        - branch: master
        - target: /srv/xpub/
        - force_fetch: True
        - force_checkout: True
        - force_reset: True
        - require:
            - elife-xpub-repository

    cmd.run:
        - name: chown -R {{ pillar.elife.deploy_user.username }}:{{ pillar.elife.deploy_user.username }} /srv/xpub
        - require:
            - builder: xpub-repository

xpub-repository-install:
    cmd.run:
        - name: |
            git checkout $(cat /srv/elife-xpub/xpub.sha1)
            npm update
            npm prune
            npm run bootstrap
        - user: {{ pillar.elife.deploy_user.username }}
        - cwd: /srv/xpub
        - require:
            - xpub-repository

xpub-db-setup:
    cmd.run:
        - name: npm run setupdb --prefix=packages/xpub-collabra/ -- --username={{ pillar.elife_xpub.database.user }} --password={{ pillar.elife_xpub.database.password }} --email={{ pillar.elife_xpub.database.email }} --collection={{ pillar.elife_xpub.database.collection }}
        - user: {{ pillar.elife.deploy_user.username }}
        - cwd: /srv/xpub
        - unless:
            - test -e /srv/xpub/packages/xpub-collabra/api/db/dev/CURRENT
        - env:
        - require:
            - xpub-repository-install

xpub-configuration:
    file.replace:
        - name: /srv/xpub/packages/xpub-collabra/config/default.js
        - pattern: "http://localhost:3000"
        - repl: {{ pillar.elife_xpub.api.endpoint }}
        - require:
            - xpub-db-setup

xpub-service:
    file.managed:
        - name: /lib/systemd/system/xpub.service
        - source: salt://elife-xpub/config/lib-systemd-system-xpub.service
        - template: jinja
        - require:
            - xpub-configuration

    cmd.run:
        # always restart, don't trust
        - name: |
            systemctl daemon-reload
            systemctl enable xpub
            systemctl restart xpub
        - require:
            - file: xpub-service

xpub-service-ready:
    cmd.run:
        - name: |
            timeout 60 sh -c 'while ! nc -q0 -w1 -z localhost 3000 </dev/null >/dev/null 2>&1; do sleep 1; done'
        - require:
            - xpub-service

xpub-nginx-vhost:
    file.managed:
        - name: /etc/nginx/sites-enabled/xpub.conf
        - source: salt://elife-xpub/config/etc-nginx-sites-enabled-xpub.conf
        - template: jinja
        - require:
            - nginx-config
            - xpub-service-ready
        - listen_in:
            - service: nginx-server-service

    
