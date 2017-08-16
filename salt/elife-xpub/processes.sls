xpub-service:
    file.managed:
        - name: /etc/init/xpub.conf
        - source: salt://elife-xpub/config/etc-init-xpub.conf
        - template: jinja
        - require:
            - elife-xpub-repository

    service.running:
        - name: xpub
        - require:
            - file: xpub-service
