#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
EXAMPLE_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)
TMP_DIR="${EXAMPLE_DIR}/tmp"
PID_FILE="${TMP_DIR}/counter_ui.pid"
LOG_FILE="${TMP_DIR}/counter_ui.log"
PORT="5173"
HOST="127.0.0.1"

mkdir -p "${TMP_DIR}"

echo "== Counter UI: ensuring port ${PORT} is free =="

# If we have a pidfile, try to stop that process first.
if [[ -f "${PID_FILE}" ]]; then
  old_pid=$(cat "${PID_FILE}" || true)
  if [[ -n "${old_pid}" ]] && kill -0 "${old_pid}" 2>/dev/null; then
    echo "Stopping previous Counter UI (pid ${old_pid})"
    kill "${old_pid}" 2>/dev/null || true
    sleep 0.3
  fi
  rm -f "${PID_FILE}"
fi

# If anything is listening on the target port, kill it.
listener_pid=$(lsof -t -iTCP:"${PORT}" -sTCP:LISTEN 2>/dev/null || true)
if [[ -n "${listener_pid}" ]]; then
  echo "Killing process listening on ${PORT}: ${listener_pid}"
  kill "${listener_pid}" 2>/dev/null || true
  sleep 0.3
fi

# Fail if the port is still in use.
if lsof -nP -iTCP:"${PORT}" -sTCP:LISTEN >/dev/null 2>&1; then
  echo "Port ${PORT} is still in use; refusing to start." >&2
  exit 1
fi

echo "== Counter UI: starting Vite on http://${HOST}:${PORT} =="
: > "${LOG_FILE}"
(
  cd "${EXAMPLE_DIR}/counter_ui"
  # Disown by running in background; capture PID.
  npm run dev -- --host "${HOST}" --port "${PORT}" --strictPort >> "${LOG_FILE}" 2>&1 &
  echo $! > "${PID_FILE}"
)

new_pid=$(cat "${PID_FILE}")
echo "Started Counter UI (pid ${new_pid})"

echo "Waiting for server to respond..."
for _ in {1..50}; do
  if curl -fsS "http://${HOST}:${PORT}/" >/dev/null 2>&1; then
    echo "OK: http://${HOST}:${PORT}/"
    exit 0
  fi
  sleep 0.1
done

echo "Server did not respond on http://${HOST}:${PORT}/" >&2
echo "Last log lines:" >&2
tail -n 30 "${LOG_FILE}" >&2 || true
exit 1
