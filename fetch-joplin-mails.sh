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

NEW_MAIL=false
fetchMails "$POP3_USER" "$POP3_PW" "$MAILDIR"

find "$MAILDIR/new" -type f -print0 | sort -z | while read -d $'\0' M
do
    echo "-------------------"
    echo "Process $M"
    NEW_MAIL=true
    addNewNoteFromMailFile "$M"
    mv "$M" "$MAILDIR/cur/`basename "$M"`:2"
done

if [[ "$NEW_MAIL" == "true" ]] ; then
    echo "-------------------"
    echo "Start Joplin Sync"
    joplin sync
fi

echo "End: `date`"
