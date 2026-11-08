#!/bin/sh

#Capture CLI arguments
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

#Validate input
if [ "$#" -ne 5 ]; then
	echo "Illegal number of parameters"
	exit 1
fi

#Parse host hardware specifications
id=1
hostname=$(hostname -f)
lscpu_out=`lscpu`
cpu_number=$(echo "$lscpu_out"  | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | grep "^Architecture:" | awk '{print $2}')
cpu_model=$(echo "$lscpu_out" | grep "^Model name:" | awk '{print $3,$4,$5,$6,$7}')
ghz=$(echo "$lscpu_out" | grep "^Model name:" | awk '{print $7}')
cpu_mhz=$(echo "$ghz" | sed 's\GHz\\' | awk '{printf "%.0f\n", $1 * 1000}')
l2_cache=$(echo "$lscpu_out" | grep "^L2 cache:" | awk '{print $3}')
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
total_mem=$(vmstat -s | grep "total memory" | awk '{print $1}')

#Insert statement
insert_stmt="INSERT INTO host_info (id, hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, \"timestamp\", total_mem) VALUES('$id', '$hostname', '$cpu_number', '$cpu_architecture', '$cpu_model', '$cpu_mhz', '$l2_cache', '$timestamp', '$total_mem');"
export PGPASSWORD=$psql_password
psql -h $psql_host -U $psql_user -d $db_name -c "$insert_stmt"
exit $?
