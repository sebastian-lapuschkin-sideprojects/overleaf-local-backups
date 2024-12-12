#!/bin/bash

# some color makros to make text output more readable
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NO_COLOR='\033[0m'

# pull changes
echo -e "${RED} EXECUTING GIT PULL BEFORE ANYTHING ELSE ${NO_COLOR}"
git pull

#OVERLEAF LOGIN CREDENTIALS!
OVERLEAF_ACCESSTOKEN= # !! PLACE YOUR ACCESS TOKEN HERE. YOU CAN GENERATE IT ON OVERLEAF.
TMP_CLONE_PATH=_tmp
KEYFILE_FOLDER=./keymaps
WAIT_TIME=10 # define a grace time in seconds to not run into API call limitations for the overleaf git integration


# NOTE: only cycling through the 2020s (and the dummy for demo purposes) for now.
for keyfile in  $KEYFILE_FOLDER/DUMMY*.csv  $(ls $KEYFILE_FOLDER/202*.csv) # in my research group, each folder name reflects the "year" a project has first been created in, and also the local folder which will be used/created by this script.
do
    echo -e "${RED} READING $keyfile ${NO_COLOR}" # full path to key file
    fname=$(basename $keyfile) # only base file name
    year="${fname%.*}"         # get file name only without extension as year

    # read keyfile line by line to clone and sync
    while read -r line
    do
        echo -e "in $year : ${YELLOW} PROCESSING KEYMAP ENTRY" $line "${NO_COLOR}"
        key="${line%;*}" # gets the git key
        val="${line#*;}" # gets the human readable project name

        #clone the current project into temporary folder
        echo -e "             ${GREEN} CLONING FROM OVERLEAF VIA GIT into $TMP_CLONE_PATH ${NO_COLOR}"
#       git clone https://$OVERLEAF_USER:$OVERLEAF_PW@git.overleaf.com/$key $TMP_CLONE_PATH # <-- old version, using password
	    git clone https://git:$OVERLEAF_ACCESSTOKEN@git.overleaf.com/$key $TMP_CLONE_PATH # <-_ new version, using access token

        # copy tmp folder without .git subfolders to destination. make sure target folder exists
        echo -e "             ${GREEN} TRANSFERRING FROM $TMP_CLONE_PATH TO TARGET $year/$val ${NO_COLOR}"
        [ ! -d "./$year" ] && mkdir "./$year" && echo -e "                   ${GREEN} GENERATED FOLDER $year ${NO_COLOR}"
        [ ! -d "./$year/$val" ] && mkdir "./$year/$val" && echo -e "                   ${GREEN} GENERATED FOLDER $year/$val ${NO_COLOR}"
        rsync -Pah --stats --exclude='.git/' $TMP_CLONE_PATH/* "./$year/$val"

        # cleaning up temporary folder
        echo -e "             ${GREEN} CLEANING UP TEMPORARY FOLDER ${NO_COLOR}"
        rm -rf $TMP_CLONE_PATH

        # commit changes (if any)
        echo -e "             ${GREEN} IF CHANGES HAVE BEEN MADE: STAGING A COMMIT FOR $year/$val ${NO_COLOR}"
        git add "./$year/$val" &&
        git commit -m "adding update for $year/$val on $(date)"

        # announcing wait time to avoid git falues due to rate limitations via overleaf
	    echo -e "             ${GREEN} IT IS NOW $(date) ${NO_COLOR}"
        echo -e "             ${GREEN} WAITING FOR ${RED} $WAIT_TIME ${GREEN} SECONDS TO AVOID RUNNING INTO OVERLEAF GIT API CALL RATE LIMITATIONS ${NO_COLOR}"
        sleep $WAIT_TIME

    
    done < $keyfile
    #ENDWHILE
done
#ENDFOR

# report status and push changes
echo -e "${RED} REPORTING VI GITLAB REPO STATUS ${NO_COLOR}"
git status

# auto-pushing (assumes ssh-key for this (ie the executing) machine has been added to the GIT server
echo -e "${RED} AUTO-PUSHING CHANGES ${NO_COLOR}"
git push && echo -e "${GREEN} ALL DONE! ${NO_COLOR}"

echo -e "${RED} CREATING READONLY EXPORT... ${NO_COLOR}"
bash ./populate-readonly.sh # optional. remove if you do not have a second read-only repo where you want to push the project files only.

