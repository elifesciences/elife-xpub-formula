echo 'hello, world':
    cmd.run

xpub-repository:
    builder.git_latest:
        - name: git@github.com:elifesciences/xpub.git
        - identity: {{ pillar.elife.projects_builder.key or '' }}
        - rev: master
        - branch: master
        - target: /srv/xpub/
        - force_fetch: True
        - force_checkout: True
        - force_reset: True

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
        - name: npm install
        - user: {{ pillar.elife.deploy_user.username }}
        - cwd: /srv/xpub
        - require:
            - file: xpub-repository
