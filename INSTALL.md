# Installation Guide

This guide covers different ways to install and deploy frab.

## Quick Links

- **Development Setup** - Local development with SQLite (see below)
- **[Docker Deployment](README.docker.md)** - Run frab with Docker and Docker Compose
- **[Kubernetes/Helm](helm/frab/README.md)** - Deploy on Kubernetes with Helm charts
- **[PaaS Deployment](README.PaaS.md)** - Deploy on Dokku or Heroku-compatible platforms
- **Production Deployment** - Traditional deployment (see below)

---

## Development Setup

To get started you need:
- Git
- Ruby (>= 3.2, recommended 3.3)
- Node.js (for JavaScript runtime)
- ImageMagick and `file` command (for image processing)

### Installation Steps

1) **Install system dependencies**

   On Debian/Ubuntu:
   ```bash
   apt-get install nodejs imagemagick file
   ```

   On macOS:
   ```bash
   brew install node imagemagick
   ```

2) **Clone the repository**

   ```bash
   git clone git://github.com/frab/frab.git
   cd frab
   ```

3) **Run setup**

   The `bin/setup` script will:
   - Install bundler and Ruby gems (excluding MySQL/PostgreSQL drivers)
   - Create `config/database.yml` from the SQLite template
   - Set up the database with seed data
   - Clear logs and temp files

   ```bash
   bin/setup
   ```

4) **(Optional) Customize settings**

   Settings are defined via environment variables using dotenv files:
   - `.env.development` - Default development settings
   - `.env.local` - Local overrides (create this for custom settings)

5) **Start the server**

   ```bash
   rails server
   ```

   Navigate to http://localhost:3000/ and login as:
   - Email: `admin@example.org`
   - Password: `test123`

### Working with Migrations

frab maintains separate schema files for different databases:
- `db/schema.rb` - SQLite/PostgreSQL schema (default for development)
- `db/schema.rb-mysql` - MySQL-specific schema with `bigint` and charset declarations

When creating migrations that change the database schema, both files need to be updated:

1. Run migrations normally:
   ```bash
   rails db:migrate
   ```

2. Update the MySQL schema file:

   **If you have MySQL configured**, use the automatic rake task:
   ```bash
   rake frab:migrate:mysql_schema
   ```
   This generates `db/schema.rb-mysql` from your MySQL database while preserving your `db/schema.rb`.

   **If you don't have MySQL**, manually update `db/schema.rb-mysql`:
   - Update the version number to match the new migration timestamp
   - Add the schema changes matching MySQL format (`bigint` instead of `integer`, etc.)

Both schema files should be committed together with your migration.

---

## Production Deployment

For production deployments, consider one of the automated approaches:
- **[Docker](README.docker.md)** - Containerized deployment
- **[Kubernetes/Helm](helm/frab/README.md)** - Cloud-native deployment
- **[PaaS platforms](README.PaaS.md)** - Dokku, Heroku, etc.

### Traditional Production Deployment

If you prefer a traditional deployment:

1) Installing database drivers

Instead of running `bin/setup` you need to run bundle install manually, so
you can choose your database gems. To avoid installing database drivers you don't
want to use, exclude drivers with

    bundle install --without="postgresql mysql"

2) Create (and possibly modify) the database configuration:

    cp config/database.yml.template-sqlite config/database.yml

3) Configuration

In Production make sure the config variables are set, copy and edit the file
`env.example` to `.env.production`.

4) Precompile assets

    rake assets:precompile

5) Security considerations

If you are running frab in a production environment you have to
take additional steps to build a secure and stable site.

* Change the password of the initial admin account
* Change the initial secret token
* Add a content disposition header, so attachments get downloaded and
are not displayed in the browser. See `./public/system/attachments/.htaccess` for an example.
* Add a gem like `exception_notification` to get emails in case of errors.

6) Start the server

To start frab in the production environment run

    RACK_ENV=production bundle rails s

Note that when seeding the database in production mode, the password for
admin@example.org will be a random one. It will be printed to the console
in when `rake db:seed` is invoked.

