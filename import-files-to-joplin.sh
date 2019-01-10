#!/usr/bin/env bash

if [[ "${1}x" == "x" ]] || [[ "${2}x" == "x" ]] ; then
    echo "Usage: `basename $0` notebook file|directory"
    exit 1
fi

# include functions
readonly CURR_WD=`pwd`
cd "$(dirname "$0")";
. ./_util-functions.sh
. ./_mail-functions.sh
. ./_joplin-functions.sh
cd ${CURR_WD}

echo "==============================="
echo "Start: `date`"

if [[ -d $2 ]]; then
    find "$2" -maxdepth 1 -type f -print0 | sort -z | while read -d $'\0' F; do
        echo "-------------------"
        addNewNoteFromGenericFile "$1" "$F"
    done
elif [[ -f $2 ]]; then
    addNewNoteFromGenericFile "$1" "$2"
else
    echo "Usage: `basename $0` notebook file|directory"
    exit 1
fi

echo "-------------------"
echo "Start Joplin Sync"

joplin sync

echo "End: `date`"
