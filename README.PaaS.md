# Deploying Frab with Dokku

[Dokku](http://dokku.viewdocs.io/dokku/) is a Platform-as-a-Service (PaaS) engine which allows for simple `git push` deployments.
It builds on [`herokuish`](https://github.com/gliderlabs/herokuish) and is highly customizable via [plugins](http://dokku.viewdocs.io/dokku/plugins/).

To deploy a Frab application with `dokku`, please proceed as follows from within your local source repository.

## 1. Setting up Dokku

Given you have access to your Dokku service via a simple shell alias (`alias dokku='ssh -t dokku@<DOKKU_HOST>'`) and `dokku version` works, you will also need to install [the PostgreSQL](https://github.com/dokku/dokku-postgres) and [Let's Encrypt](https://github.com/dokku/dokku-letsencrypt) plugins.

You can then proceed setting up your application.

```
dokku create <APP_NAME>
```

Set up your Ruby version:

```
dokku config:set CUSTOM_RUBY_VERSION 2.3
```

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

Pipe this configuration to Dokku with

    dokku config:set <APP_NAME> `paste -d " " -s .env`

### Database setup

The associated database service is created and linked with

    dokku postgresql:create <DB_NAME>
    dokku postgresql:link <APP_NAME> <DB_NAME>

`dokku config <APP_NAME>` should now report your whole configuration.

### TLS setup

This will only work after your application is (already partly) running, due to the way the Let's Encrypt plugin works, so let's

## 3. Deploy Frab!

Add the desired `APP_FQDN` domain to the application and remove the standard Dokku subdomain `APP_NAME.DOKKU_HOST` for later generation of a valid TLS certificate.

### domain configuration

    dokku domains:add <APP_NAME> <APP_FQDN>
    dokku domains:remove <APP_NAME> <APP_NAME.DOKKU_HOST>

Only then issue

### git deployment

    git remote add dokku dokku@<DOKKU_HOST>:<APP_NAME>
    git push dokku master

### TLS setup

To omit an appearing **502 Bad Gateway** error, we finish the TLS setup with

    dokku letsencrypt <APP_NAME>

After this has completed successfully, manually load the database schema

    dokku run <APP_NAME> bundle exec rake db:setup

---

That's it. Your application should be running at `<PROTO>://<APP_NAME>.<DOKKU_HOST>`.
