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

		if grep -R "$users" $secure
			then
			# T check: Duplicate found, user already existed
			log "Duplicate found, user: ${users} already existed"

		else
			password=$RANDOM
			useradd "$users"
			passwd "$password"
			add_user_to_sudoers "$users"
			enable_ssh_access "$users"
			groupadd $users
			# echo "$users:$password" | chpasswd


			log "User unique, saving user credential"
		        custom="${groups},${users}_group"
                        credential="${users},${password}"
			log "saved user: APPROVED"
			echo $credential >> $secure
		fi
	done < $1




else
	log "EXPECTED A .txt file parameter -"
	echo 'EXPECTED A .txt file paramater -'

fi

echo "Done processing"


enable_ssh_access() {
    username=$1   # Username as input

    # Add user's public key to the authorized_keys file
    ssh_dir="/home/$username/.ssh"
    authorized_keys_file="$ssh_dir/authorized_keys"

    # Create the .ssh directory if it doesn't exist
    if [ ! -d "$ssh_dir" ]; then
        mkdir "$ssh_dir"
        chmod 700 "$ssh_dir"
    fi

    # Prompt the user to enter the public key
    echo "Enter the public key for $username:"
    read -r public_key

    # Add the public key to the authorized_keys file
    echo "$public_key" >> "$authorized_keys_file"
    chmod 600 "$authorized_keys_file"

    # Set ownership and permissions for the .ssh directory
    chown -R "$username:$username" "$ssh_dir"

    echo "SSH access enabled for $username."
}

add_user_to_sudoers() {
    username=$1   # Username as input

    # Add user to sudo group
    usermod -aG sudo "$username"

    echo "User $username added to the sudoers group."
}