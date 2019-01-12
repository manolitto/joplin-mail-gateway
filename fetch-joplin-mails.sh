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

fetchMails "$POP3_USER" "$POP3_PW" "$MAILDIR"

find "$MAILDIR/new" -type f -print0 | sort -z | while read -d $'\0' M
do
    echo "-------------------"
    echo "Process $M"
    addNewNoteFromMailFile "$M"
    mv "$M" "$MAILDIR/cur/`basename "$M"`:2"
done

echo "-------------------"
echo "Start Joplin Sync"
joplin sync

echo "End: `date`"
