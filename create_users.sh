#!/bin/bash

mkdir -p var/secure
mkdir -p var/log
secure=var/secure/user_passwords.csv
log=var/log/user_management.log

set -eo pipefail
DEBUG_MODE=${DEBUG_MODE:-false}
ALL_LOG_FILE=$log

function log(){
	local message=$1
	local timestamp="$(date +%D-%T)"
	local log_message="[$timestamp] > $message"

	# echo $log_message
	echo $log_message >> $ALL_LOG_FILE
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
		personalgroup="$users,$groups"
		echo $personalgroup

		if grep -q $users $secure
			then
			# T check: Duplicate found, user already existed
			log "Duplicate found, user: ${users} already existed"

		else
			log "User unique, saving user credential"
		        custom="${groups},${users}_group"
                        credential="${users},${RANDOM}"
			log "saved user: APPROVED"
			echo $credential >> $secure
		fi
	done < $1




else
	log "EXPECTED A .txt file parameter -"
	echo 'EXPECTED A .txt file paramater -'

fi

echo "Done processing"
