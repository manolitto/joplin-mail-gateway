#!/usr/bin/env bash

readonly DECODEMAIL_BIN=$(dirname "$0")/decodemail.py

## Usage: getMailSubject mail-file
function getMailSubject {
    ${DECODEMAIL_BIN} Subject: $1 | cut -c 10-999
}

## Usage: getTitleFromSubject subject
function getTitleFromSubject {
    echo -n "$1" | python3 -c 'import sys,re; s=sys.stdin.read(); s=re.sub("(#\w+\s*)","",s); s=re.sub(r"(@\w+\s*)","",s); print(s);'
}

## Usage: getTagsFromSubject subject
function getTagsFromSubject {
    echo -n "$1" | python3 -c 'import sys,re; s=sys.stdin.read(); s=re.findall("(?:#)(\w+)",s); print(" ".join(s));'
}

## Usage: getNotebookFromSubject subject default-notebook
function getNotebookFromSubject {
    local NB=`echo -n "$1" | python3 -c 'import sys,re; s=sys.stdin.read(); s=re.search("@(\w+)",s); print(s.group(1)) if s is not None else print("")'`
    if [[ "${NB}x" == "x" ]]; then
        echo "$2"
    else
        echo "$NB"
    fi
}


#---
## Usage: fetchMails user password mail-dir
#---
function fetchMails {
    echo "Fetching mails"
    getmail_fetch ${GETMAIL_OPTS} -p ${POP3_PORT} ${POP3_HOST} "$1" "$2" "$3"
}
