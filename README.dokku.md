# Deploying Frab with Dokku

Dokku is a Platform-as-a-Service (PaaS) engine which allows for simple `git push` deployments.
It builds on Heroku's `buildpack`s and is higly customizable.

To deploy a Frab application with `dokku`, please proceed as follows:

## 1. Setting up Dokku

Given you have access to your Dokku service via a simple alias (`alias dokku='ssh -t dokku@<DOKKU_HOST>'`) and `dokku version` works, do the following:

```
dokku create <APP_NAME>
```

The `.env` environment would then look similarily to

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

Pipe this configuration to dokku with

    dokku config:set frab `paste -d " " -s .env`

Make sure you are using a branch which provides Ruby 2.2.3 in the `Gemfile` and the `web` process (only) in the `Procfile`.

```
dokku postgresql:create <DB_NAME>
dokku postgresql:link <APP_NAME> <DB_NAME>
```

## 2. Setting up frab

Then use the output of the second command to set up your `production` database connection in `config/database.yml`:

```
production:
  adapter: postgresql
  encoding: unicode
  database: <DB_NAME>
  username: <DB_USER>
  password: <DB_PASS>
  host: postgresql
  pool: 5
  timeout: 5000
```

and force commit this file to your git tree, until the use of a `DATABASE_URL` environment variable is implemented.

## 3. Deploying Frab

    git remote add dokku dokku@<DOKKU_HOST>:<APP_NAME>
    git push dokku master

After this has completed successfully, you need to manually load the database schema with

    dokku run frab bundle exec rake db:setup

---

That's it. Your application should be running at `<PROTO>://<APP_NAME>.<DOKKU_HOST>`.
