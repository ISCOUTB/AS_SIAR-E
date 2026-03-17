#!/usr/bin/env bash
set -euo pipefail

# Script para ejecutar pytest con coverage y generar coverage.xml + html
# Uso: ./scripts/run_tests_with_coverage.sh

ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT_DIR"

# Activar virtualenv si existe
if [ -f backend/.venv/bin/activate ]; then
  # shellcheck disable=SC1091
  source backend/.venv/bin/activate
fi

# Asegurarse de que pytest-cov esté instalado
python -m pip install --upgrade pip
python -m pip install pytest pytest-cov >/dev/null

# Ejecutar tests (mide cobertura sobre backend)
pytest --cov=backend --cov-report=xml:coverage.xml --cov-report=html:htmlcov -q

echo "Coverage reports generated: coverage.xml and htmlcov/"
