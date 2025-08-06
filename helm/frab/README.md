# Frab Helm Chart

This Helm chart deploys Frab, a conference management system, on Kubernetes with SQLite3 as the default database.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (for persistent volumes)

## Installation

### Quick Start (SQLite3)

```bash
# Install with default SQLite3 configuration
helm install frab ./helm/frab

# Or install with custom values
helm install frab ./helm/frab -f custom-values.yaml
```

### Configuration

The following table lists the configurable parameters and their default values:

#### Basic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Container image repository | `ghcr.io/frab/frab` |
| `image.tag` | Container image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

#### Database Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `database.type` | Database type (sqlite3, postgresql, mysql) | `sqlite3` |
| `database.sqlite.path` | SQLite database file path | `/rails/data/database.db` |

#### Persistence

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.data.enabled` | Enable database storage (SQLite only) | `true` |
| `persistence.data.size` | Database PVC size | `5Gi` |
| `persistence.data.accessMode` | Database PVC access mode | `ReadWriteOnce` |
| `persistence.data.storageClass` | Database PVC storage class | `""` |
| `persistence.public.enabled` | Enable public files storage | `true` |
| `persistence.public.size` | Public files PVC size | `10Gi` |
| `persistence.public.accessMode` | Public files PVC access mode | `ReadWriteOnce` |
| `persistence.public.storageClass` | Public files PVC storage class | `""` |
| `persistence.customViews.enabled` | Enable custom views storage | `false` |
| `persistence.customViews.size` | Custom views PVC size | `1Gi` |
| `persistence.customViews.accessMode` | Custom views PVC access mode | `ReadWriteOnce` |
| `persistence.customViews.storageClass` | Custom views PVC storage class | `""` |

#### Frab Application Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `frab.host` | Application hostname | `frab.local` |
| `frab.protocol` | Protocol (http/https) | `http` |
| `frab.fromEmail` | From email address | `frab@localhost` |
| `frab.currency.unit` | Currency unit | `€` |
| `frab.maxAttachmentSizeMb` | Max attachment size in MB | `42` |

## Volume Best Practices

### SQLite3 (Default)
- Uses separate PersistentVolumes for database and public files
- Recommended for development and small deployments
- Storage class should support ReadWriteOnce access mode
- Consider backup strategies for both volumes

### Volume Mount Points
- `/rails/data` - Database and application data (persistent)
- `/rails/public/system` - Uploaded files like PDF slides and attachments (persistent)
- `/rails/app/views/custom` - Custom view templates for UI overrides (optional)

### Storage Recommendations
- **Development**: Use default storage class with 5Gi for data, 10Gi for public files
- **Production**: Use fast SSD storage class with appropriate backup policies
- **High Availability**: Consider external database for multiple replicas (disable data persistence)

### Storage Configuration Examples

**SQLite with both volumes:**
```yaml
persistence:
  data:
    enabled: true
    size: 10Gi
    storageClass: "fast-ssd"
  public:
    enabled: true
    size: 20Gi
    storageClass: "standard"
```

**External database (PostgreSQL/MySQL):**
```yaml
persistence:
  data:
    enabled: false  # No data volume needed
  public:
    enabled: true
    size: 50Gi
```

**With custom view overrides:**
```yaml
persistence:
  data:
    enabled: true
  public:
    enabled: true
  customViews:
    enabled: true
    size: 1Gi
```

## Security Configuration

### Secrets Management
The chart automatically creates secrets for:
- `SECRET_KEY_BASE` (auto-generated if not provided)
- `DATABASE_URL` (constructed from database configuration)
- SMTP passwords
- OAuth client secrets
- LDAP bind passwords

### Security Context
- Runs as non-root user (UID 1000)
- Drops all capabilities
- Uses read-only root filesystem where possible

## External Database Setup

### PostgreSQL
```yaml
database:
  type: postgresql
  postgresql:
    host: postgres.example.com
    port: 5432
    database: frab
    username: frab
    password: "your-password"
```

### MySQL
```yaml
database:
  type: mysql
  mysql:
    host: mysql.example.com
    port: 3306
    database: frab
    username: frab
    password: "your-password"
```

## Authentication Providers

### Google OAuth
```yaml
frab:
  google:
    enabled: true
    clientId: "your-client-id"
    clientSecret: "your-client-secret"
```

### LDAP
```yaml
frab:
  ldap:
    enabled: true
    host: ldap.example.com
    port: 389
    method: tls
    baseDn: "ou=users,dc=example,dc=com"
    uid: uid
```

### OpenID Connect
```yaml
frab:
  oidc:
    enabled: true
    issuer: "https://oidc.example.com"
    clientId: "your-client-id"
    clientSecret: "your-client-secret"
    name: "Company SSO"
```

## Rails-Specific Features

### Database Setup and Migrations
Database setup and migrations are handled by separate Helm hook jobs:

**Fresh Installations:**
- Install job runs `rails db:setup` (or `rails db:create db:schema:load` + optional seeding)
- Much faster than running all historical migrations
- Creates default admin user when `seedData: true`

**Upgrades:**
- Upgrade job runs `rails db:migrate` to apply new schema changes
- Only runs incremental migrations since last version

```yaml
rails:
  runMigrations: true
  seedData: true  # Creates default admin user on install
  migrationJobTtl: 300  # Cleanup install/upgrade jobs after 5 minutes
```

**Job Cleanup:**
- Install and upgrade jobs automatically clean up after completion
- Default TTL: 5 minutes (configurable via `migrationJobTtl`)
- Jobs use `ttlSecondsAfterFinished` for automatic Kubernetes cleanup

### Default Admin User
When `rails.seedData: true`, a default admin user is created:
- **Email**: `admin@example.org` (hardcoded)
- **Username**: `admin` / `admin_127`
- **Password**: 
  - Development: `test123` (fixed)
  - Production: Random 32-character password (printed to install job logs)
- **Role**: Admin with full access

### Caching
Configure Rails caching with Redis or Memcached:
```yaml
rails:
  cache:
    enabled: true
    type: redis
    redis:
      host: redis.example.com
      port: 6379
      database: 0
```

### Session Storage
Configure session storage (cookie, Redis, or Active Record):
```yaml
rails:
  sessionStore:
    type: redis
    redis:
      host: redis.example.com
      port: 6379
      database: 1
```

### Asset Pipeline
The chart handles Rails asset precompilation:
```yaml
rails:
  precompileAssets: true
  assetHost: "https://cdn.example.com"  # Optional CDN
```

### Graceful Shutdown
Proper Rails application shutdown handling:
- 30-second termination grace period
- PreStop hook with sleep delay
- Sidekiq quiet mode before termination

## Monitoring and Health Checks

The chart includes comprehensive health monitoring:
- **Health Endpoint**: `/health` endpoint with database connectivity checks
- **Startup Probe**: Allows 5 minutes for Rails application boot
- **Liveness Probe**: Monitors application health via `/health` endpoint
- **Readiness Probe**: Ensures application is ready to serve traffic via `/health` endpoint
- **Resource Limits**: Memory and CPU limits optimized for PDF processing
- **Integration Testing**: `helm test` validates health endpoint connectivity
- **Optional HorizontalPodAutoscaler**: Scale based on CPU/memory usage

## Upgrading

```bash
# Upgrade with new values
helm upgrade frab ./helm/frab -f custom-values.yaml

# Rollback if needed
helm rollback frab 1
```

## Uninstallation

```bash
# Uninstall the release
helm uninstall frab

# Note: PersistentVolumeClaims are not automatically deleted
# Delete manually if needed:
kubectl delete pvc frab-data frab-public
```

## Testing

The chart includes comprehensive unit and integration tests.

### Unit Tests (helm-unittest)

Validate template rendering without deploying to Kubernetes:

```bash
# Run all unit tests
./tests/run-unit-tests.sh

# Run specific test suite
helm unittest . -f tests/configmap_test.yaml
```

**Test Coverage**: 62 tests across 5 suites covering ConfigMaps, Secrets, Deployments, database configurations, and authentication providers.

### Integration Tests (helm test)

Test actual deployments in Kubernetes with real connectivity checks:

```bash
# Test with default SQLite configuration
helm install frab . && helm test frab

# Test with custom configuration
helm install frab-custom . -f custom-values.yaml
helm test frab-custom
```

**Test Types:**
- **Health Test**: Verifies application startup and `/health` endpoint connectivity
- **Environment Validation**: Validates configuration values and required environment variables
- **Feature Tests**: Only run when specific features are enabled:
  - Google OAuth configuration validation (when `frab.google.enabled: true`)
  - LDAP configuration validation (when `frab.ldap.enabled: true`) 
  - Redis/cache configuration validation (when Redis features are enabled)

**Test Coverage**: Tests automatically adapt to your configuration - only relevant tests run based on enabled features.

See [`tests/TESTING.md`](tests/TESTING.md) for detailed testing documentation.

## Troubleshooting

### Common Issues

1. **Pod not starting**: Check logs with `kubectl logs deployment/frab`
2. **Database connection issues**: Verify database configuration and connectivity
3. **Permission issues**: Ensure proper security context and volume permissions
4. **Out of storage**: Check PVC size and available storage

### Debugging Commands

```bash
# Check pod status
kubectl get pods

# View logs
kubectl logs -f deployment/frab

# Describe deployment
kubectl describe deployment frab

# Check persistent volumes
kubectl get pv,pvc

# Test template rendering
helm template . -f custom-values.yaml
```
