#!/usr/bin/env bash

# ---------- Configuration ---------------

POP3_USER="unknown"
POP3_PW="unknown"
POP3_HOST="pop.gmail.com"
POP3_PORT=995

GETMAIL_OPTS=--ssl

# As soon as your setup is tested and working you may add the -d flag
# to delete fetched mails from your provider inbox:
#GETMAIL_OPTS=--ssl -d

DEFAULT_TITLE_PREFIX="New Note"
DEFAULT_NOTEBOOK="Inbox"

# Shall new notebooks (given via @-syntax) be created automatically?
AUTO_CREATE_NOTEBOOK=false
