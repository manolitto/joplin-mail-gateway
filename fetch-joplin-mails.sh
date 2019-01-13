#!/usr/bin/env bash

# ---- Configuration ----
readonly MAILDIR=~/joplin-mailbox/

# include functions
readonly CURR_WD=`pwd`
cd "$(dirname "$0")";
. ./config-defaults.sh
. ./config.sh
. ./_util-functions.sh
. ./_mail-functions.sh
. ./_joplin-functions.sh
cd ${CURR_WD}

echo "==============================="
echo "Start: `date`"

NEW_MAIL=0

fetchMails "$POP3_USER" "$POP3_PW" "$MAILDIR"

NEW_MAIL_FILES=`find "$MAILDIR/new" -type f -print0 | sort -z`
while read -d $'\0' M; do
    echo "-------------------"
    echo "Process $M"
    let NEW_MAIL=1
    addNewNoteFromMailFile "$M"
    if [[ $? -eq 0 ]]; then
        mv "$M" "$MAILDIR/cur/`basename "$M"`:2"
    else
        echo "Error: Mail could not be added - leaving in inbox"
    fi
done <<< "$NEW_MAIL_FILES"

if [[ ${NEW_MAIL} -eq 1 ]] ; then
    echo "-------------------"
    echo "Start Joplin Sync"
    joplin sync
fi

echo "End: `date`"
