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
    orcid:
        client_id: fake_client_id
        client_secret: fake_client_secret
    pubsweet:
        base_url: fake_pubsweet_baseurl
        secret: fake_pubsweet_secret
    s3:
        bucket: fake_bucket
    meca:
        sftp:
            connectionOptions:
                host: fake_host
                port: fake_port
                username: fake_username
                password: fake_password
            remotePath: fake_path
        api_key: ThisIsNotAnApiKey
    deployment_target: ci

elife:
    aws:
        access_key_id: AKIAFAKE
        secret_access_key: fake
