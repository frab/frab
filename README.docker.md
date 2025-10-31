# Docker Setup

Frab can be run inside a Docker container. Basic familiarity with Docker is assumed in this guide.

A `Dockerfile` and `docker-compose.yml` file are provided for easy deployment.

## Downloading the Docker Image

Pre-built Docker images are available from GitHub Container Registry:

```bash
docker pull ghcr.io/frab/frab:latest
```

## Building the Docker Image

You can also build the image yourself:

```bash
docker-compose build
```

or

```bash
docker build -t ghcr.io/frab/frab:latest .
```

## Configuration

The Dockerfile sets default environment variables including SQLite database support. You should customize these for production by editing `docker-compose.yml` or passing environment variables with `-e` flags.

**Important:** Generate a secure `SECRET_KEY_BASE`:
```bash
docker run --rm ghcr.io/frab/frab:latest bundle exec rails secret
```

### Database Configuration

**SQLite (default):**
- Database location: `/rails/data/database.db`
- Mount a volume to `/rails/data` for persistence

**PostgreSQL/MySQL:**
- Set `DATABASE_URL` environment variable
- Example: `DATABASE_URL=postgresql://user:password@host/database`
- The included `docker-compose.yml` shows PostgreSQL setup

### Persistent Storage

Mount volumes for persistent data:
- `/rails/data` - SQLite database files
- `/rails/public` - Event attachments and uploaded files

## Running with Docker Compose

Start frab with the included docker-compose setup:

```bash
docker-compose up
```

The initial admin credentials will be printed to stdout on first run:
- Email: `admin@example.org`
- Password: (randomly generated and displayed)

To run as a background service:

```bash
docker-compose up -d
```

View logs:
```bash
docker-compose logs -f frab
```

## Running Standalone

To run without docker-compose:

```bash
# With SQLite (data volume for persistence)
docker run -d \
  -p 3000:3000 \
  -v frab-data:/rails/data \
  -v frab-public:/rails/public \
  -e SECRET_KEY_BASE=your_secret_key \
  -e FRAB_HOST=your-domain.com \
  -e FRAB_PROTOCOL=https \
  ghcr.io/frab/frab:latest

# With PostgreSQL
docker run -d \
  -p 3000:3000 \
  -v frab-public:/rails/public \
  -e SECRET_KEY_BASE=your_secret_key \
  -e DATABASE_URL=postgresql://user:password@db-host/frab \
  -e FRAB_HOST=your-domain.com \
  -e FRAB_PROTOCOL=https \
  ghcr.io/frab/frab:latest
```

Access frab at http://localhost:3000
