#!/bin/bash

# Configuration constants
DBHOST='localhost'
DBUSER='monitor'
DBPASSWD=''
DBNAME='monitor'

shopt -s lastpipe

OLDIFS=$IFS
IFS=$'\n'

# Retrieving hosts list to ping
pinghost=()
mysql -h $DBHOST -u $DBUSER --password=$DBPASSWD $DBNAME -se 'SELECT * FROM pinghost' | while read -a row; do
	pinghost+=(${row[@]})
done

# Retrieving filesystems to track
filesystem=()
mysql -h $DBHOST -u $DBUSER --password=$DBPASSWD $DBNAME -se 'SELECT * FROM filesystem' | while read -a row; do
		filesystem+=(${row[@]})
done

IFS=$OLDIFS

# Deleting old data
mysql -h $DBHOST -u $DBUSER --password=$DBPASSWD $DBNAME << EOF
DELETE
FROM data
WHERE id NOT IN (
	SELECT id
	FROM (
		SELECT id
		FROM data
		ORDER BY id DESC
		LIMIT 288
	) AS tmp
);
EOF

mysql -h $DBHOST -u $DBUSER --password=$DBPASSWD $DBNAME << EOF
DELETE
FROM cpudata
WHERE idData NOT IN (
	SELECT id
	FROM (
		SELECT id
		FROM data
		ORDER BY id DESC
		LIMIT 288
	) AS tmp
);
EOF

mysql -h $DBHOST -u $DBUSER --password=$DBPASSWD $DBNAME << EOF
DELETE
FROM fsdata
WHERE idData NOT IN (
	SELECT id
	FROM (
		SELECT id
		FROM data
		ORDER BY id DESC
		LIMIT 288
	) AS tmp
);
EOF

mysql -h $DBHOST -u $DBUSER --password=$DBPASSWD $DBNAME << EOF
DELETE
FROM pingdata
WHERE idData NOT IN (
	SELECT id
	FROM (
		SELECT id
		FROM data
		ORDER BY id DESC
		LIMIT 288
	) AS tmp
);
EOF

# Current time
clock=$(date +"%s")

# Load average for last 1, 5, 15 minutes
loadavg=($(uptime | awk -F'average: ' '{print $2}' | sed -r 's/, / /g;s/,/./g'))

# CPU usage in %
cpuusage=$(mpstat 1 1 | sed -n '4p' | awk '{print $11}' | awk -F',' '{print 100 - ($1 "." $2)}')

# Total processes
nbprocesses=$(ps -N -p 2 --ppid 2 | wc -l)

# Total connections
nbconnections=$(netstat -ntuw | sed -n '3,$p' | wc -l)

# Total hosts
nbhosts=$(netstat -ntuw | sed -n '3,$p' | awk '{print $5}' | awk -F':' '{print $1}' | sort | uniq -c | wc -l)

# Total clients
nbusers=$(uptime | awk -F', *' '{print $3}' | sed -r 's/([0-9]+) users?/\1/g')

# RAM usage in M
totalram=$(free -mo | grep 'Mem:' | awk '{print $2}')
usedram=$(free -mo | grep 'Mem:' | awk '{print $3}')
buffersram=$(free -mo | grep 'Mem:' | awk '{print $6}')
cachedram=$(free -mo | grep 'Mem:' | awk '{print $7}')
sysram=$(($usedram - $buffersram - $cachedram))

# RAM usage in %
usageram=$(awk "BEGIN{print $usedram / $totalram * 100}")
buffersusageram=$(awk "BEGIN{print $buffersram / $totalram * 100}")
cachedusageram=$(awk "BEGIN{print $cachedram / $totalram * 100}")
sysusageram=$(awk "BEGIN{print $sysram / $totalram * 100}")

# Storing fresh data
datarowid=$(mysql -h $DBHOST -u $DBUSER --password=$DBPASSWD $DBNAME << EOF | sed -n '$p'
INSERT INTO data (
	clock,
	loadAvgOne,
	loadAvgFive,
	loadAvgFifteen,
	overallCpuUsage,
	processes,
	connections,
	hosts,
	users,
	memTotalUsed,
	memTotalUsage,
	memBuffersUsed,
	memBuffersUsage,
	memCachedUsed,
	memCachedUsage,
	memSystemUsed,
	memSystemUsage
)
VALUES (
	'$clock',
	'${loadavg[0]}',
	'${loadavg[1]}',
	'${loadavg[2]}',
	'$cpuusage',
	'$nbprocesses',
	'$nbconnections',
	'$nbhosts',
	'$nbusers',
	'$usedram',
	'$usageram',
	'$buffersram',
	'$buffersusageram',
	'$cachedram',
	'$cachedusageram',
	'$sysram',
	'$sysusageram'
);
SELECT LAST_INSERT_ID();
EOF
)

# Track per core CPU usage
nbcpu=$(grep 'processor' /proc/cpuinfo | wc -l)
for (( i=0; i < nbcpu; i++ )); do
	# CPU core usage in %
	coreusage=$(mpstat -P $i 1 1 | sed -n '4p' | awk '{print $11}' | awk -F',' '{print 100 - ($1 "." $2)}')

	# Storing fresh data
	mysql -h $DBHOST -u $DBUSER --password=$DBPASSWD $DBNAME << EOF
INSERT INTO cpudata (
	idCpu,
	idData,
	\`usage\`
)
VALUES (
	'$i',
	'$datarowid',
	'$coreusage'
);
EOF
done

# Ping every host
for host in "${pinghost[@]}"; do
	host=($host)

	time=$(ping -c 1 ${host[1]} | grep -E "time=")

	# Ping in ms
	if [[ $? -eq 1 ]]; then
		time=0
	else
		time=$(echo $time | sed -r 's/.*time=([0-9.]+) ms/\1/g')
	fi

	# Storing fresh data
	mysql -h $DBHOST -u $DBUSER --password=$DBPASSWD $DBNAME << EOF
INSERT INTO pingdata (
	idHost,
	idData,
	\`time\`
)
VALUES (
	'${host[0]}',
	'$datarowid',
	'$time'
);
EOF
done

# Track every filesystem
for fs in "${filesystem[@]}"; do
	fs=($fs)

	totalfs=$(df -T | grep -E " ${fs[1]}\$" | sed -n '1p' | awk '{print $3}')
	usedfs=$(df -T | grep -E " ${fs[1]}\$" | sed -n '1p' | awk '{print $4}')

	# Filesystem usage in %
	usagefs=$(awk "BEGIN{print $usedfs / $totalfs * 100}")
	
	# Filesystem usage in M
	usedfs=$(df -T --block-size=1M | grep -E " ${fs[1]}\$" | sed -n '1p' | awk '{print $4}')

	# Storing fresh data
	mysql -h $DBHOST -u $DBUSER --password=$DBPASSWD $DBNAME << EOF
INSERT INTO fsdata (
	idFs,
	idData,
	used,
	\`usage\`
)
VALUES (
	'${fs[0]}',
	'$datarowid',
	'$usedfs',
	'$usagefs'
);
EOF
done
