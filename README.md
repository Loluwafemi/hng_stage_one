# HNG11_stage_one
## JOIN HNG
[HNG INTERN ](https://hng.tech/internship)
[HNG PREMIUM](https://hng.tech/premium)
> ARTICLE ON BASH
## This article discuss how automating file contents passed through a bash command -argument

    bash create_users.sh *.txt
    
Provided the passed in text file contains the criteria, which is having a username/string separated by ';' e.g
username;group1,group2,...
the system will do just fine to:
	1.  read each line
	2. check if user is already checked, by checking a secured folder
	3. append a new custom group to the user's group
	4. assign a password (random key generated) to the user and label as credential
	5. append the credential to the user_passwords.csv file
	6. and repeat the same for the rest of the lines.

On performing this task, the automation is design to:
	1.  handle logs: saving a structured log to the .log file for proper debugging
	2. check if the dependency is found: the text file to read from
	3. and process automation flow.
	
    
    #!/bin/bash
    


> Dev Ops Stage One