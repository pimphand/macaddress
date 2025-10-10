su - centreon-broker -s /bin/bash
/usr/sbin/cbd -v -C /etc/centreon-broker/central-broker.json
exit

sudo -u centreon-broker /usr/sbin/cbd -v -c /etc/centreon-broker/central-broker.json


cat <<EOF > /etc/centreon-gorgone/config.d/40-gorgoned.yaml
name:  gorgoned-poller-50-13
description: Configuration for poller poller-50-13
gorgone:
  gorgonecore:
    id: 8
    external_com_type: tcp
    external_com_path: "*:5556"
    authorized_clients: 
      - key: 1bi0QLwo55Zp0AJvv87wODy5fy3Zn7raNOWiiePGx5A
    privkey: "/var/lib/centreon-gorgone/.keys/rsakey.priv.pem"
    pubkey: "/var/lib/centreon-gorgone/.keys/rsakey.pub.pem"
  modules:
    - name: engine
      package: gorgone::modules::centreon::engine::hooks
      enable: true
      command_file: "/var/lib/centreon-engine/rw/centengine.cmd"

EOF
