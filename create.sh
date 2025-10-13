sudo tee /etc/centreon-broker/dwiki.json >/dev/null <<'JSON'
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
      "host": "118.201.5.173",
      "port": 5669,
      "failover": false,
      "compression": "lz4"
    }
  ]
}
JSON

sudo mkdir -p /var/log/centreon-broker
sudo chown -R centreon-broker:centreon-broker /etc/centreon-broker /var/log/centreon-broker
sudo chmod 750 /etc/centreon-broker
