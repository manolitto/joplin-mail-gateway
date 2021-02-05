# joplin-mail-gateway

Simple (bash-based) mail gateway for the open source note taking and to-do application
[Joplin](https://joplin.cozic.net/).

## Rationale

This tool provides a solution for emailing content directly into your Joplin notes.

You may send or forward an email to a dedicated email address. This email is than
automatically delivered to your personal Joplin notes. Attachments (PDFs, Images, ...)
will automatically be included in the note. In addition text is automatically
scanned from images via OCR. This extracted text is added at the bottom of the note so
that it is easily searchable in Joplin. 

## Features

- automatically fetch mails from a certain mail account and add all new mails as Joplin notes
- automatically add mail attachments
- provide tags via mail subject (with #-syntax)
- choose notebook via mail subject (with @-syntax)
- automatically run OCR on images and add text to bottom of note
- automatically add png thumbnails for PDF attachments
- automatically add PDF text part to bottom of note

## Prerequisites

1. [**Joplin**](https://joplin.cozic.net/) terminal application installed and configured

    see https://joplin.cozic.net/

    Tested with `joplin 1.0.119 (prod)`

2. [**pdftoppm**](https://poppler.freedesktop.org/) and [**pdftotext**](https://poppler.freedesktop.org/) must be installed

        sudo apt update
        sudo apt install poppler-utils

    Tested with `pdftoppm 3.03` and `pdftotext 3.03`    

4. [**tesseract**](https://github.com/tesseract-ocr/tesseract) must be installed

        sudo apt update
        sudo apt-get install tesseract-ocr
        
    And for German training files:
     
        sudo apt-get install tesseract-ocr-deu 

    Tested with `tesseract 3.04.01`

5. [**getmail**](http://pyropus.ca/software/getmail/) must be installed 

        sudo apt-get update
        sudo apt-get install getmail4

    Tested with `getmail_fetch 4.48.0`

6. [**ripmime**](https://github.com/inflex/ripMIME) must be installed

        sudo apt-get update
        sudo apt install ripmime

    Tested with `ripmime v1.4.0.9`

7. [**python 3**](https://www.python.org/) must be installed

        sudo apt-get update
        sudo apt install python3

    Tested with `python3 3.5.2`

## Install

1. Clone from github

        git clone https://github.com/manolitto/joplin-mail-gateway.git
        
2. Create a mail directory for incoming mails with following structure:

        mkdir -p ~/joplin-mailbox/new
        mkdir -p ~/joplin-mailbox/cur
        mkdir -p ~/joplin-mailbox/tmp

3. Create a log directory

        sudo mkdir /var/log/fetch-joplin-mails
        sudo chown $USER /var/log/fetch-joplin-mails
        
4. Create a new mail account at your preferred email provider that supports POP3
        
5. Create the configuration file
        
        cp config-sample.sh config.sh
        chmod 700 config.sh 
        
5. Change default configuration by editing `config.sh`

        readonly POP3_USER="your-email-user@your-provider"
        readonly POP3_PW="your-super-secret-pop3-pw"
        readonly POP3_HOST="pop.gmail.com"
        readonly POP3_PORT=995
        readonly DEFAULT_TITLE_PREFIX="Neue Notiz"
        readonly DEFAULT_NOTEBOOK="Import"

7. Test your configuration
        
        ./fetch-joplin-mails.sh  
        
8. Add cron job

        crontab -e

    Add the following line:

        */5 * * * * ~/joplin-mail-gateway/fetch-joplin-mails.sh >>/var/log/fetch-joplin-mails/fetch.log 2>&1           

## Running from a docker container

The gateway can be run from a docker container. The included Dockerfile does everything from installing joplin to 
fetching emails

To setup the docker container :

1. prepare the mail-gateway by editing the `config.sh` file as described above

2. edit the `joplin-config.json` file with your Joplin sync settings. Template files are availables. Simple remove the `.template` extension

3. build the container by running

        docker build . -t joplin_gateway

4. run the container

        docker run -d joplin_gateway