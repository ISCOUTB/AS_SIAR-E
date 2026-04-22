#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$ROOT_DIR/logs"
mkdir -p "$LOG_DIR"

echo "[start_all] Working dir: $ROOT_DIR"

cd "$ROOT_DIR"

# Start backend (uvicorn)
echo "[start_all] Starting backend (uvicorn) on :8000..."
if [ -f "$ROOT_DIR/backend/.venv/bin/activate" ]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/backend/.venv/bin/activate"
else
  echo "[start_all] Warning: virtualenv not found at backend/.venv — using system python environment"
fi

nohup uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 >"$LOG_DIR/backend.log" 2>&1 &
BACKEND_PID=$!
echo "[start_all] Backend PID: $BACKEND_PID (logs: $LOG_DIR/backend.log)"
echo "\n[start_all] Ready. Backend: http://localhost:8000"
echo "[start_all] To stop: kill $BACKEND_PID"

trap 'echo "[start_all] Stopping..."; kill $BACKEND_PID || true; exit' INT TERM

wait $BACKEND_PID || true
