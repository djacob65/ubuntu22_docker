#!/bin/bash

# Default parameters
CLOUD=genostack
CLOUDFILE=~/.config/openstack/clouds.yaml
OS_SCRIPTS=`dirname $(which openstack)`
OS_PASSWORD=
VM_TMPL=ubuntu

if [ -z $OS_PASSWORD ]; then
  echo "Please enter your OpenStack Password, then [Enter] :"
  read -sr OS_PASSWORD
fi

alias ostack="$OS_SCRIPTS/openstack --os-cloud=$CLOUD --os-password $OS_PASSWORD"

echo "Server list:";   ostack server list
echo
echo "Flavor list:";   ostack flavor list
echo
echo "Keypair list:";  ostack keypair list
echo
echo "Image list:";   ostack image list | grep -E "(${VM_TMPL}|^\+|Status)"
echo
