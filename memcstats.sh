#!/bin/bash

MC_IP=10.183.37.110
MC_PORT=11211
MC_LOG=/var/log/memcstats.log
MC_CON=""

DTS=`date -R`
MC_CON=$(/bin/nc -w 5 -i 1 $MC_IP $MC_PORT << EOF | grep "STAT curr_connections"
stats
quit
EOF
)

echo "[$DTS] $MC_CON" >> $MC_LOG

exit 0

