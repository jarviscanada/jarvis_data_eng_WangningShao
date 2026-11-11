#!/bin/sh

#Capture CLI arguments
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

#Validate arguments
if [ "$#" -ne 5 ]; then
	echo "Illegal number of parameters"
	exit 1
fi

#Save machine statistics in MB and current machine hostname to variables
vmstat_mb=$(vmstat --unit M)
hostname=$(hostname -f)

#Parse hardware usage info
timestamp=$(vmstat -t | tail -n 1 | awk '{print $(NF-1),$NF}')
host_id="(SELECT id FROM host_info WHERE hostname='$hostname')"
memory_free=$(echo "$vmstat_mb" | awk '{print $4}'| tail -n 1)
cpu_idle=$(echo "$vmstat_mb" | awk '{print $15}' | tail -n 1)
cpu_kernel=$(echo "$vmstat_mb" | tail -n 1 | awk '{print $14}')
disk_io=$(vmstat -d | awk '{print $10}' | tail -n 1)
disk_available=$(df -BM / | awk '{print $4}' | tail -n 1 | sed 's/M//')

#Insert statement
insert_stmt="INSERT INTO host_usage(\"timestamp\", host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available) VALUES('$timestamp', $host_id, '$memory_free', '$cpu_idle', '$cpu_kernel', '$disk_io', '$disk_available');"

#setup pass environment variable for execute query
export PGPASSWORD=$psql_password
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?
