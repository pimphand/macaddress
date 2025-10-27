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
