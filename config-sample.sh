#!/usr/bin/env bash

# ---------- Configuration ---------------

POP3_USER="your-email-user@your-provider"
POP3_PW="your-super-secret-pop3-pw"
POP3_HOST="pop.gmail.com"
POP3_PORT=995

# Note: By default emails do get not deleted from your inbox which results in duplicate notes on every run.
# This is for the safety of your data and protects you from losing emails due to a bad setup.
# However, as soon as your setup is tested and working you may add the --delete flag to the getmail options.
# Alternative: if your email provider allows it (Gmail does) you may also set your inbox options to
# "archive mails when POP3 fetched".
#GETMAIL_OPTS="--ssl --delete"

#DEFAULT_TITLE_PREFIX="Neue Notiz"
#DEFAULT_NOTEBOOK="Import"

#AUTO_CREATE_NOTEBOOK=false

