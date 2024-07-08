#!/bin/bash

mkdir -p var/secure
mkdir -p var/log
secure=var/secure/user_passwords.csv
log=var/log/user_management.log

# set permission for user to read, write and execute to user_passwords.cvs
chmod 700 "./$secure"

set -x

if [ "$EUID" -ne 0 ]
then
echo "System need to run on root"
exit 1
fi

set -eo pipefail
DEBUG_MODE=${DEBUG_MODE:-false}
ALL_LOG_FILE=$log

# a structure logging function to save activity logs
function log(){
	local message=$1
	local timestamp="$(date +%D-%T)"
	local log_message="[$timestamp] > $message"

	# echo $log_message
	echo $log_message >> $ALL_LOG_FILE
}

> "$log"
> "$secure"

# giving user permission to read and write to user_passowrds.cvs
chmod 600 "./$secure"
# create a user to home directory and secure it with password
function createuser(){
	local user=$1
	local groups=$2
	if id "$user" &>/dev/null
		then
		# T check: Duplicate found, user already existed
		log "Duplicate found, user: ${user} already existed"

	else
		password=$RANDOM
		# create user and put it in home dir
		useradd -m "$user"

		# set user password
		credential="$user:$password"
		echo $credential | chpasswd
		echo "Secure user: $user" | tee -a "$log"
		echo "$user,$password" >> $secure
		chown root:root "$secure"
		chown 600 "$secure"

		log "saved and secured user: $user"

		log "User unique, saving user credential"
		log "Adding user to groups"
		creategroup $user $groups
	fi
}

# add user to groups and assign a custom group
function creategroup(){
	local user=$1
	local groups=$2
	array_group=${groups//,/ }
	echo "Groups are $groups"
	for group in $array_group
	do 
	if ! getent group "$group" &>/dev/null
	then
	groupadd "$group"
	log "creating group $group"

	echo "Created group $group."
	else
	echo "Group: $group already existed"
	log "Group: $group already existed"
	fi

	usermod -a -G "$group" "$user"

	if [ $? -ne 0 ]
	then
	log 'fail to add user to group'
	echo 'fail to add user to group'
	else
	log "User: $user added to group: $group"
	fi
	done
}

# check if the input is a file: else send a msg
if [[ -f "${1-}" ]]
	echo "Found Dependencies: $1"
	echo "processing $1"
	log "Checking dependencies .txt"
	# global check: creating dependencies
	then
	while read line
		do
	# for each line: seperate name and group and put as variable
			users=$(echo $line | cut -d';' -f 1)
			groups=$(echo $line | cut -d';' -f 2)
			createuser $users $groups
		done < $1

	else
		log "EXPECTED A .txt file parameter -"
		echo 'EXPECTED A .txt file paramater -'

fi

echo "Done processing"