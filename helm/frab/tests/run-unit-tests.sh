#!/bin/bash

# Helm unittest runner script for Frab chart
# This script installs helm-unittest if needed and runs all unit tests

set -e

CHART_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TESTS_DIR="$CHART_DIR/tests"

echo "Frab Helm Chart Unit Tests"
echo "=========================="
echo "Chart directory: $CHART_DIR"
echo "Tests directory: $TESTS_DIR"
echo

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo "❌ Helm is not installed. Please install Helm first."
    exit 1
fi

# Check if helm-unittest plugin is installed
if ! helm plugin list | grep -q unittest; then
    echo "📦 Installing helm-unittest plugin..."
    helm plugin install https://github.com/helm-unittest/helm-unittest
    echo "✅ helm-unittest plugin installed"
else
    echo "✅ helm-unittest plugin already installed"
fi

echo
echo "🧪 Running Helm unit tests..."
echo

# Change to chart directory
cd "$CHART_DIR"

# Run all unit tests
if helm unittest .; then
    echo
    echo "🎉 All unit tests passed!"
    exit 0
else
    echo
    echo "❌ Some unit tests failed!"
    exit 1
fi