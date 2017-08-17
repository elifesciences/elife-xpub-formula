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

    file.directory:
        - name: /srv/xpub
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group
        - require:
            - builder: xpub-repository

    cmd.run:
        - name: |
            git checkout $(cat /srv/elife-xpub/xpub.sha1)
            npm install
        - user: {{ pillar.elife.deploy_user.username }}
        - cwd: /srv/xpub
        - require:
            - file: xpub-repository

xpub-db-setup:
    cmd.run:
        - name: npm run setupdb
        - user: {{ pillar.elife.deploy_user.username }}
        - cwd: /srv/xpub
        - unless:
            - test -e /srv/xpub/api/db/dev/CURRENT
        - env:
            - PUBSWEET_DB_ADMIN: '{{ pillar.elife_xpub.database.user }}'
            - PUBSWEET_DB_ADMIN_PASSWORD: '{{ pillar.elife_xpub.database.password }}'
            - PUBSWEET_DB_ADMIN_EMAIL: '{{ pillar.elife_xpub.database.email }}'
            - PUBSWEET_DB_COLLECTION: '{{ pillar.elife_xpub.database.collection }}'
        - require:
            - xpub-repository
