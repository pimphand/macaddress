cat <<EOF > /etc/centreon-gorgone/config.d/40-gorgoned.yaml
name:  gorgoned-poller-50
description: Configuration for poller poller-50
gorgone:
  gorgonecore:
    id: 6
    external_com_type: tcp
    external_com_path: "*:5556"
    authorized_clients: 
      - key: runI2NQL75wFLlrNn34O3BW2eF4ZpHaIiZjh59D7pSg
    privkey: "/var/lib/centreon-gorgone/.keys/rsakey.priv.pem"
    pubkey: "/var/lib/centreon-gorgone/.keys/rsakey.pub.pem"
  modules:
    - name: engine
      package: gorgone::modules::centreon::engine::hooks
      enable: true
      command_file: ""

EOF

systemctl restart gorgoned
systemctl status gorgoned
systemctl restart gorgoned

822-1376-9b4cf4d7-s3lab.awetonet.io
sudo -u centreon php /usr/share/centreon/bin/console debug:router | grep api

/var/log/centreon-engine/centengine.log

192.168.53.10   nms-dev.awetonet.io centreon-central
nano /etc/hosts

nc -zv nms-dev.awetonet.io 5669
sudo -u centreon gorgonectl ping poll-53

/bin/sh -c '/usr/lib/centreon/plugins/centreon_hp_procurve_snmp.pl --plugin=network::hp::procurve::snmp::plugin --mode=interfaces --hostname=192.168.53.10 --snmp-version= --snmp-community= --name --add-status --add-traffic'

cat /etc/centreon/conf.pm | grep password

# Default SNMP version = 2c
if (!defined($plugin->{option_results}->{snmp_version}) || $plugin->{option_results}->{snmp_version} eq '') {
    $plugin->{option_results}->{snmp_version} = '2c';
}

