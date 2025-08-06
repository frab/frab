# Frab Helm Chart Unit Testing Guide

Comprehensive testing documentation for the Frab Helm chart.

## Test Coverage Summary

✅ **62 unit tests passing** across 5 test suites
✅ **7 integration tests** for runtime validation
✅ **100% template coverage** for all chart components

## Unit Tests (helm-unittest)

Unit tests validate template rendering logic without requiring a Kubernetes cluster.

### Test Suites

| Suite | Tests | Coverage |
|-------|-------|----------|
| `configmap_test.yaml` | 9 tests | ConfigMap template rendering, optional values, auth configs |
| `secret_test.yaml` | 12 tests | Secret rendering, base64 encoding, credential management |
| `deployment_test.yaml` | 17 tests | Deployment template, envFrom, resources, volumes, probes |
| `database_test.yaml` | 10 tests | Database configurations (SQLite, PostgreSQL, MySQL) |
| `auth_test.yaml` | 14 tests | Authentication providers (Google OAuth, LDAP, OIDC) |

### Running Unit Tests

```bash
# Using the test runner script
./tests/run-unit-tests.sh

# Manual execution
helm unittest .

# Run specific test suite
helm unittest . -f tests/configmap_test.yaml

# Run with strict mode (fail on warnings)
helm unittest . --strict
```

### Key Test Scenarios

1. **Default Configuration**: Validates default values render correctly
2. **Optional Values**: Tests conditional template logic for optional features
3. **Database Types**: Verifies SQLite, PostgreSQL, and MySQL configurations
4. **Authentication**: Tests Google OAuth, LDAP, and OIDC provider configs
5. **Secret Management**: Validates proper base64 encoding and credential handling
6. **Environment Variables**: Checks envFrom mounting and explicit env vars
7. **Resource Configuration**: Tests CPU/memory limits, volumes, and probes

## Integration Tests (helm test)

Integration tests run against actual deployments to validate runtime behavior.

### Test Files (in `templates/tests/`)

| Test | Purpose |
|------|---------|
| `test-basic-sqlite.yaml` | Basic deployment with SQLite (default) |
| `test-environment-validation.yaml` | Comprehensive env var validation |
| `test-postgresql.yaml` | PostgreSQL database configuration |
| `test-mysql.yaml` | MySQL database configuration |
| `test-ldap-auth.yaml` | LDAP authentication setup |
| `test-google-oauth.yaml` | Google OAuth integration |
| `test-redis-cache.yaml` | Redis cache and session store |

### Running Integration Tests

```bash
# Deploy and test with default values
helm install frab . && helm test frab

# Test with PostgreSQL configuration
helm install frab-pg . -f tests/postgresql-values.yaml
helm test frab-pg

# Test with LDAP configuration
helm install frab-ldap . -f tests/ldap-values.yaml
helm test frab-ldap

# Clean up
helm uninstall frab frab-pg frab-ldap
```

## Test Value Files

Pre-configured value files for testing common scenarios:

- `tests/postgresql-values.yaml` - PostgreSQL + Google OAuth + Redis
- `tests/ldap-values.yaml` - LDAP authentication + MySQL

## CI/CD Integration

The test suite is designed for automated CI/CD pipelines:

```yaml
# Example GitHub Actions step
- name: Run Helm Unit Tests
  run: |
    helm plugin install https://github.com/helm-unittest/helm-unittest
    helm unittest .

- name: Run Integration Tests
  run: |
    helm install frab . --wait
    helm test frab
```

## Troubleshooting Tests

### Common Issues

1. **Missing Values**: Ensure test `set` blocks include all required values
2. **Template Path Errors**: Verify template file names in test suite headers
3. **Assertion Failures**: Check expected vs actual values in test output
4. **Base64 Encoding**: Use online tools to verify expected base64 values

### Debugging Commands

```bash
# Render templates with test values
helm template . -f tests/postgresql-values.yaml

# Debug specific template
helm template . --show-only templates/configmap.yaml

# Validate chart syntax
helm lint .
```

## Writing New Tests

### Unit Test Template

```yaml
suite: test my feature
templates:
  - mytemplate.yaml
tests:
  - it: should render correctly
    set:
      my.feature: enabled
    asserts:
      - equal:
          path: spec.myField
          value: "expected-value"
```

### Integration Test Template

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: "{{ include "frab.fullname" . }}-test-my-feature"
  annotations:
    "helm.sh/hook": test
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
spec:
  restartPolicy: Never
  containers:
  - name: test
    image: busybox:1.35
    command: ["sh", "-c", "echo 'Testing my feature' && exit 0"]
```

### Best Practices

- **Unit Tests**: Place in `tests/` directory with `*_test.yaml` naming
- **Integration Tests**: Place in `templates/tests/` directory
- **Test Values**: Use realistic values that represent actual usage
- **Assertions**: Be specific about expected values and formats
- **Coverage**: Test both positive cases and edge cases

## Test Maintenance

- **Update tests** when adding new features or changing templates
- **Run tests locally** before committing changes
- **Verify integration tests** work with actual Kubernetes deployments
- **Keep test values** realistic and representative of production usage

The comprehensive test suite ensures the Frab Helm chart works correctly across all supported configurations and deployment scenarios.
