#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
EXAMPLE_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)
TMP_DIR="${EXAMPLE_DIR}/tmp"
PID_FILE="${TMP_DIR}/counter_ui.pid"
PORT="5173"

if [[ -f "${PID_FILE}" ]]; then
  pid=$(cat "${PID_FILE}" || true)
  if [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null; then
    echo "Stopping Counter UI (pid ${pid})"
    kill "${pid}" 2>/dev/null || true
    sleep 0.3
  fi
  rm -f "${PID_FILE}"
fi

listener_pid=$(lsof -t -iTCP:"${PORT}" -sTCP:LISTEN 2>/dev/null || true)
if [[ -n "${listener_pid}" ]]; then
  echo "Killing listener on ${PORT}: ${listener_pid}"
  kill "${listener_pid}" 2>/dev/null || true
fi

echo "Stopped (best-effort)."
