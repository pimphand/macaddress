su - centreon-broker -s /bin/bash
/usr/sbin/cbd -v -C /etc/centreon-broker/central-broker.json
exit

sudo -u centreon-broker /usr/sbin/cbd -v -c /etc/centreon-broker/central-broker.json
