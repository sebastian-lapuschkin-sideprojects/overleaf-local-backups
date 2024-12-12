#!/bin/bash

READONLY_LOCATION= # ADD HERE THE LOCAL FULL PATH TO YOUR SECONDARY READ ONLY GIT PROJECT WHICH ONLY SHOULD CONTAIN THE PROJECT FILES.

# some color makros to make text output more readable
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NO_COLOR='\033[0m'


if [ -d "$READONLY_LOCATION" ];
then
	echo -e "${GREEN} Folder '$READONLY_LOCATION' exists. Writing readonly backup for department. ${NO_COLOR}"
	git archive --output _tmp.tar main

	du -sh _tmp.tar
	
	# delete files which should not be carried over
	echo -e "    ${YELLOW} Removing files from export which should not be carried over. ${NO_COLOR}"
	tar -f _tmp.tar --delete keymaps *.md *.sh 

	# exporting
	echo -e "    ${YELLOW} Exporting to $READONLY_LOCATION. ${NO_COLOR}"	
	tar -x -f _tmp.tar -C $READONLY_LOCATION

	# cleanup
	echo -e "    ${YELLOW} Deleting temporary archive. ${NO_COLOR}"
	rm _tmp.tar

	# pushing changes in target folder
	echo -e "    ${YELLOW} adding, committing, pushing changes in '$READONLY_LOCATION'. ${NO_COLOR}"
	cd $READONLY_LOCATION && git add * && git status && git commit -m "updating all the changes on $(date)" && git push

	echo -e "    ${GREEN} all done! ${NO_COLOR}"
	

else
	echo "${RED} Folder '$READONLY_LOCATION' does NOT exist. Aborting. ${NO_COLOR}"
fi
