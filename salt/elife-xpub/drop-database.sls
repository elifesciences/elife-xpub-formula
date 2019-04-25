# drops and recreates the database on every run
# do not use in real environments!

{% if salt['elife.cfg']('project.node', 1) == 1 %}
elife-xpub-database-drop:
    cmd.run:
        - name: |
            /usr/local/bin/wait-database.sh
            /usr/local/bin/setup-database.sh
        - user: {{ pillar.elife.deploy_user.username }}
        - cwd: /srv/elife-xpub
        - env:
            - DROP: 1
            - TIMEOUT: 30
        - require:
            - elife-xpub-database-setup
{% endif %}
