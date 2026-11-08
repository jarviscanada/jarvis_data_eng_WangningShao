#!/bin/sh

# Capture CLI arguments
cmd=$1
db_username=$2
db_password=$3

# Check docker status, if not active run the start command
sudo systemctl status docker || sudo systemctl start docker

# Check container status and store into container_status
docker container inspect jrvs-psql
container_status=$?

# handles create/start/stop command
case "$1" in
	create)
		# check whether a container exist
		if [ $container_status -eq 0 ]; then
			echo 'Container already exist!'
			exit 1
		fi
		# check number of line arguments
		if [ $# -ne 3 ]; then
			echo 'Create requires three arguments!'
			exit 1
		fi
		#create container
		docker volume create pgdata
		#start container
		docker run --name jrvs-psql -e POSTGRES_PASSWORD=$db_password -d -v pgdata:/var/lib/postgresql/data -p 5432:5432 postgres:9.6-alpine
		exit $?
		;;
	start|stop)
		# Check instance status; exit 1 if container has not been created
		if [ $container_status -ne 0 ]; then
			echo 'No container found!'
			exit 1
		fi
		#execute the command
		docker container $cmd jrvs-psql
		exit $?
		;;
	*)
		echo 'Illegal commands!'
		echo 'Accepted commands are create/start/stop'
		exit 1
		;;
esac
