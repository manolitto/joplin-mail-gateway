#!/usr/bin/env bash

readonly DECODEMAIL_BIN=$(dirname "$0")/decodemail.py

## Usage: getMailSubject mail-file
function getMailSubject {
    ${DECODEMAIL_BIN} Subject: $1
}

