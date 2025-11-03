cat <<EOF > /etc/centreon-gorgone/config.d/40-gorgoned.yaml
name:  gorgoned-poller 50.13
description: Configuration for poller poller 50.13
gorgone:
  gorgonecore:
    id: 2
    external_com_type: tcp
    external_com_path: "*:5556"
    authorized_clients: 
      - key: pbkXIQ1g6ENpiNqGlX-8515Fs4pi56wsqgZ5iZGbBnY
    privkey: "/var/lib/centreon-gorgone/.keys/rsakey.priv.pem"
    pubkey: "/var/lib/centreon-gorgone/.keys/rsakey.pub.pem"
  modules:
    - name: engine
      package: gorgone::modules::centreon::engine::hooks
      enable: true
      command_file: "/var/lib/centreon-engine/rw/centengine.cmd"

EOF

mysql -u centreon -p centreon
SELECT id, name, ns_ip_address, engine_start_command FROM nagios_server;


centreon -u admin -p 'C3ntr30n!0101' -o HTPL -a ADD -v "HP-Switch-Template;HP ProCurve Monitoring Template"
