#!/usr/bin/env bash
# dwiki.sh
# Minimal Centreon poller broker setup script (creates dwiki.json + systemd service)
# Usage: sudo bash dwiki.sh
set -euo pipefail
IFS=$'\n\t'

# ----- CONFIG -----
CENTRAL_IP="118.201.5.173"
CENTRAL_PORT="5669"
BROKER_JSON_PATH="/etc/centreon-broker/dwiki.json"
LOG_DIR="/var/log/centreon-broker"
SERVICE_PATH="/etc/systemd/system/centreon-broker.service"
CBD_PATH="/usr/sbin/cbd"       # adjust if cbd is elsewhere (use `command -v cbd` to verify)
BROKER_USER="centreon-broker"
BROKER_GROUP="centreon-broker"
ENGINE_SERVICE_NAME="centengine"  # service name for poller engine
# ------------------

echo "== dwiki.sh: Starting minimal poller broker setup =="
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Exit."
  exit 2
fi

# Ensure directory exists
mkdir -p "$(dirname "$BROKER_JSON_PATH")"
mkdir -p "$LOG_DIR"

# Create minimal JSON config (dwiki.json)
cat > "$BROKER_JSON_PATH" <<'JSON'
{
  "daemon": {
    "event_queue_max_size": 100000
  },
  "log": {
    "level": "info",
    "type": "file",
    "filename": "/var/log/centreon-broker/dwiki.log"
  },
  "input": [
    {
      "name": "central-collector",
      "type": "memory"
    }
  ],
  "output": [
    {
      "name": "to-central",
      "type": "tcp",
      "host": "CENTRAL_IP_REPLACE",
      "port": CENTRAL_PORT_REPLACE,
      "failover": false,
      "compression": "lz4"
    }
  ]
}
JSON

# Replace placeholders with values
sed -i "s/CENTRAL_IP_REPLACE/${CENTRAL_IP}/g" "$BROKER_JSON_PATH"
sed -i "s/CENTRAL_PORT_REPLACE/${CENTRAL_PORT}/g" "$BROKER_JSON_PATH"

echo "Wrote broker JSON to $BROKER_JSON_PATH"

# Create log dir and set ownership/permissions
getent group "$BROKER_GROUP" >/dev/null || groupadd -r "$BROKER_GROUP" || true
getent passwd "$BROKER_USER" >/dev/null || useradd -r -s /usr/sbin/nologin -g "$BROKER_GROUP" "$BROKER_USER" || true

chown -R "${BROKER_USER}:${BROKER_GROUP}" "$(dirname "$BROKER_JSON_PATH")" "$LOG_DIR" || true
chmod 750 "$(dirname "$BROKER_JSON_PATH")" || true

echo "Permissions set on $BROKER_JSON_PATH and $LOG_DIR"

# Create systemd service if cbd exists (or create anyway using configured path)
if [ ! -x "$CBD_PATH" ]; then
  # attempt to locate cbd
  FOUND=$(command -v cbd || true)
  if [ -n "$FOUND" ]; then
    CBD_PATH="$FOUND"
    echo "Found cbd at $CBD_PATH"
  else
    echo "Warning: cbd not found at $CBD_PATH and not found in PATH. Please install centreon-broker or adjust CBD_PATH in script."
  fi
fi

cat > "$SERVICE_PATH" <<UNIT
[Unit]
Description=Centreon Broker (cbd)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=${CBD_PATH} -c ${BROKER_JSON_PATH}
Restart=on-failure
User=${BROKER_USER}
Group=${BROKER_GROUP}

[Install]
WantedBy=multi-user.target
UNIT

echo "Created systemd unit at $SERVICE_PATH"

# Reload systemd, enable and start broker service
systemctl daemon-reload
systemctl enable --now centreon-broker.service || systemctl enable --now cbd.service || true
sleep 1

# Try to start by service name if earlier enable didn't start
if ! systemctl is-active --quiet centreon-broker.service; then
  echo "Attempting to start centreon-broker.service"
  systemctl start centreon-broker.service || true
fi

echo "centreon-broker service status:"
systemctl status centreon-broker.service --no-pager || true

# Enable and start poller engine (centengine)
if systemctl list-unit-files | grep -q "^${ENGINE_SERVICE_NAME}"; then
  systemctl enable --now "${ENGINE_SERVICE_NAME}" || true
  echo "${ENGINE_SERVICE_NAME} status:"
  systemctl status "${ENGINE_SERVICE_NAME}" --no-pager || true
else
  echo "Note: Engine service '${ENGINE_SERVICE_NAME}' not found via systemd (package may use different name)."
fi

# Network checks: test connectivity to central on port 5669
echo
echo "== Connectivity checks =="
if command -v nc >/dev/null 2>&1; then
  echo "Testing TCP to ${CENTRAL_IP}:${CENTRAL_PORT} using nc..."
  nc -vz "${CENTRAL_IP}" "${CENTRAL_PORT}" || echo "nc reported failure (timeout/refused) — check firewall/NAT."
else
  echo "nc not installed; skipping nc test. You can run: nc -vz ${CENTRAL_IP} ${CENTRAL_PORT}"
fi

echo "Local listening ports (filtering 5556/5669 if present):"
ss -ltnp | egrep "5556|5669" || ss -ltnp | head -n 20 || true

echo
echo "== Completed =="
echo "Broker file: $BROKER_JSON_PATH"
echo "Systemd unit: $SERVICE_PATH"
echo
echo "Next recommended steps:"
echo " - If cbd binary is in a different location, edit $SERVICE_PATH ExecStart and run: systemctl daemon-reload"
echo " - If central cannot be reached, verify NAT/firewall from poller to ${CENTRAL_IP}:${CENTRAL_PORT}"
echo " - When GUI export works, Central will overwrite this JSON; this is a temporary manual config."
echo
