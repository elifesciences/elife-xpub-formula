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
        - require:
            - xpub-repository

    file.directory:
        - name: /srv/elife-xpub
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group
        - require:
            - builder: elife-xpub-repository
