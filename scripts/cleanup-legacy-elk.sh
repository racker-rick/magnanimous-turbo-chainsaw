#!/usr/bin/env bash

# Remove old container definitions and delete from inventory
rm /etc/openstack_deploy/env.d/{elasticsearch,kibana,logstash}.yml || true
rm /etc/openstack_deploy/conf.d/{elasticsearch,kibana,logstash}.yml || true

# Cleanup all legacy systems prior to deployment
source /opt/bootstrap-embedded-ansible.sh
ansible-playbook "/opt/magnanimous-turbo-chainsaw/playbooks/cleanup-legacy-filebeat.yml"
deactivate

pushd /opt/openstack-ansible/playbooks
  # Not needed unless containers exist in inventory
  openstack-ansible lxc-containers-destroy.yml -e "force_containers_destroy=yes" -e "force_containers_data_destroy=yes" --limit 'lxc_hosts:elasticsearch_all:kibana_all:logstash_all:elk_all'

  for i in $(../scripts/inventory-manage.py -l | grep -e apm -e elastic -e kibana -e logstash | awk '{print $2}'); do
    echo "Removing $i"
    /opt/openstack-ansible/scripts/inventory-manage.py -r "${i}"
  done
popd