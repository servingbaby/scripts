#!/bin/sh

SERVER=localhost
LOG=/var/log/mysql_threads.log
DTS=$(date +"%Y-%m-%d %H:%M:%S %Z")

THREADS=$(mysql -h ${SERVER} -B -N -e "SHOW STATUS LIKE 'Threads_connected';" | tr "\011" " ")
USERS=$(mysql -h ${SERVER} -B -N -e "SELECT DISTINCT USER AS users, COUNT(*) FROM information_schema.processlist GROUP BY users;" | tr "\011" ":" | tr "\n" "," | sed '$s/.$//')

echo "${DTS} ${THREADS}, Users_connected [${USERS}]" >> ${LOG}

exit 0

