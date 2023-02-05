#!/bin/bash
# This script automatically update ansible host inventory

TAG='ASG-test'
AWSBIN='/usr/local/bin/aws'
awsDiscovery() {
	$AWSBIN ec2 describe-instances --filters Name=tag:aws:autoscaling:groupName,Values=PAADEU2_ASG \
		--query Reservations[*].Instances[*].NetworkInterfaces[*].{PrivateIpAddresses:PrivateIpAddress} > /etc/ansible/ips.list
	}
inventoryUpdate() {
	echo > /etc/ansible/hosts 
  	echo [webservers] > /etc/ansible/hosts
	for instance in `cat /etc/ansible/ips.list`
	do
		ssh-keyscan -H $instance >> ~/.ssh/known_hosts
echo "
$instance ansible_user=ec2-user ansible_ssh_private_key_file=/etc/ansible/key.pem
" >> /etc/ansible/hosts
       done
}
instanceUpdate() {
  sleep 30
  ansible-playbook MyPlaybook.yaml 
  sleep 30
}

awsDiscovery
inventoryUpdate
#instanceUpdate