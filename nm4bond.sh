#!/bin/bash
#
# Create a bond interface on RHEL7 / CentOS7 using pure nmcli methods
# on a fresh installation (or vanilla networking) that was built using
# NetworkManager. IPv4 only.
#
# Required: first parameter passed is the fully configured interface with
# IP(s)/CIDR, Gateway and DNS; these values will be extracted and applied
# to the new bond0 and set as a default route
#
# BACK UP YOUR CONFIGS FIRST

if [ $# -ne 3 ]; then
  echo "Usage:   $0 <bond name> <1st slave> <2nd slave>"
  echo "Example: $0 bond0 eth0 eth1"
  exit 1
fi

BOND=$1
SLAVE1=$2
SLAVE2=$3

# Build the basic bond in HA mode (most common)
nmcli con add autoconnect yes type bond con-name ${BOND} ifname ${BOND} \
  mode active-backup miimon 100

# Set a high priority to keep gateway as the default route
nmcli con mod ${BOND} connection.autoconnect-priority 99 \
  ipv6.method link-local

# Pull existing IPv4
IPV4=($(nmcli -f \
  ipv4.method,ipv4.addresses,ipv4.gateway,ipv4.dns,ipv4.dns-search \
  con show ${SLAVE1} | awk '{print $2}'))

# Configure the bond
nmcli con mod ${BOND} ipv4.method ${IPV4[0]} \
  ipv4.addresses ${IPV4[1]} ipv4.gateway ${IPV4[2]} \
  ipv4.dns ${IPV4[3]} ipv4.dns-search ${IPV4[4]} \
  ipv4.never-default no ipv4.ignore-auto-dns no

# Remove then add the interfaces as slaves
nmcli con del ${SLAVE1}
nmcli con add autoconnect yes type bond-slave \
  con-name ${SLAVE1} ifname ${SLAVE1} master ${BOND}

nmcli con del ${SLAVE2}
nmcli con add autoconnect yes type bond-slave \
  con-name ${SLAVE2} ifname ${SLAVE2} master ${BOND}

exit 0

