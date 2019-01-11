# This file should be kept in sync with the AWS defaults:
# https://github.com/elifesciences/builder-configuration/blob/master/pillar/elife-xpub-public.sls
#
elife_xpub:
    api:
        endpoint: http://192.168.33.44
    database:
        user: pubsweet
        password: pubsweet
        email: fake@example.com
    ink:
        user: fakeuser
        password: fakepassword
        endpoint: http://ink-api.coko.foundation
    pubsweet:
        base_url: fake_pubsweet_baseurl
        secret: fake_pubsweet_secret
    s3:
        bucket: fake_bucket
    meca:
        sftp:
            connection:
                host: localhost
                port: 1022
                username: ejpdummy
                password: ejpdummy
            remote_path: fake_path
        api_key: ThisIsNotAnApiKey
    api_gateway:
        secret: fake_credential
    mailer:
        host: smtp.example.com
        port: 25
        user: myuser
        pass: mypass
    deployment_target: formula

elife:
    aws:
        access_key_id: AKIAFAKE
        secret_access_key: fake
    # for testing
    sidecars:
        containers:
            sftp:
                name: sftp
                image: elifesciences/sftp
                tag: 20190110
                command: ejpdummy:ejpdummy:::meca
                ports:
                    # SSH/SFTP
                    - "2222:22"
                enabled: true
