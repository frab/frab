# Deploying Frab with Dokku

[Dokku](http://dokku.viewdocs.io/dokku/) is a Platform-as-a-Service (PaaS) engine which allows for simple `git push` deployments.
It builds on [`herokuish`](https://github.com/gliderlabs/herokuish) and is highly customizable via [plugins](http://dokku.viewdocs.io/dokku/plugins/).

To deploy a Frab application with `dokku`, please proceed as follows from within your local source repository.

## 1. Setting up Dokku

From your local machine SSH into your server, or create a simple shell alias to access Dokku (`alias dokku='ssh -t dokku@<DOKKU_HOST>'`). Check if `dokku version` works.

You will also need to install [the PostgreSQL](https://github.com/dokku/dokku-postgres) and [Let's Encrypt](https://github.com/dokku/dokku-letsencrypt) plugins.

    sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git

    sudo dokku plugin:install https://github.com/dokku/dokku-letsencrypt

You can then proceed setting up your application.

    dokku apps:create <APP_NAME>

## 2. Setting up frab

For your application you need

1. an [environmental configuration](http://12factor.net/config),
2. an [attached database](http://12factor.net/backing-services) and
3. a valid TLS setup due to Rails' [CSRF](https://en.wikipedia.org/wiki/Cross-site_request_forgery) protection.

### Environmental configuration

Your local `.env` environment file could then look similarly to

```
SECRET_KEY_BASE=<should_be_longer_than_32_chars, 'pwgen 32' suffices>
FRAB_HOST=<APP_FQDN=APP_NAME.DOKKU_HOST>
FRAB_PROTOCOL=<http|https>
FROM_EMAIL=<sender@host.tld>
SMTP_ADDRESS=<SMTP MX>
SMTP_PORT=25
SMTP_NOTLS=<true|false>
SMTP_USER_NAME=
SMTP_PASSWORD=
BUNDLE_WITHOUT=development:test:mysql:sqlite3
RAILS_SERVE_STATIC_FILES=true
```

Here is an example .env file using SMTP with TLS:

```
SECRET_KEY_BASE=eem4ohxaeXu4aem3chohThooZeecei4w
FRAB_HOST=subdomain.domain.com
FRAB_PROTOCOL=https
FROM_EMAIL=sender@host.tld
SMTP_ADDRESS=smtp.host.com
SMTP_PORT=587
SMTP_NOTLS=false
SMTP_USER_NAME=user
SMTP_PASSWORD=em3chohThooZeec
BUNDLE_WITHOUT=development:test:mysql:sqlite3
RAILS_SERVE_STATIC_FILES=true

```

Pipe this configuration to Dokku with

    dokku config:set <APP_NAME> `paste -d " " -s .env`

### Database setup

The associated database service is created and linked with

    dokku postgresql:create <DB_NAME>
    dokku postgresql:link <DB_NAME> <APP_NAME>

`dokku config <APP_NAME>` should now report your whole configuration.

### TLS setup

This will only work after your application is (already partly) running, due to the way the Let's Encrypt plugin works, so let's

## 3. Deploy Frab!

Add the desired `APP_FQDN` domain to the application and remove the standard Dokku subdomain `APP_NAME.DOKKU_HOST` for later generation of a valid TLS certificate.

### domain configuration

    dokku domains:add <APP_NAME> <APP_FQDN>
    dokku domains:remove <APP_NAME> <APP_NAME.DOKKU_HOST>

Only then deploy your app via git.

### Git deployment

In the folder of your local frab repo on your local machine, run:

    git remote add dokku dokku@<DOKKU_HOST>:<APP_NAME>
    git push dokku master

> On Windows, git and SSH are sometimes tricky to get working on the command-line. If you are getting errors like:

```
Permission denied (publickey).
fatal: Could not read from remote repository.
```

> Use Sourcetree and add your Dokku private SSH key there via "Tools > Launch SSH Agent". Then push via Sourcetree to your dokku remote (select from dropdown).

### Troubleshooting

If push fails, maybe you need to delete the Dockerfile in your repo, so that dokku will know to build using herokuish.

### TLS setup

To omit an appearing **502 Bad Gateway** error, we finish the TLS setup.

Configure your email address:

    dokku config:set --no-restart <APP_NAME> DOKKU_LETSENCRYPT_EMAIL=<YOUR_EMAIL>

Set a custom domain that you own for your application:

    dokku domains:set <APP_NAME> your.domain.com

Enable letsencrypt:

    dokku letsencrypt:enable <APP_NAME>

Optionally: Enable auto-renewal:

    dokku letsencrypt:cron-job --add

### Seed the Database

After this has completed successfully, manually load the database schema

    dokku run <APP_NAME> bundle exec rake db:setup

Your application should be running at `https://<APP_FQDN>`. If not, you may have to

### Configure Ports

dokku proxy:ports-set <APP_NAME> http:80:3000 https:443:3000
