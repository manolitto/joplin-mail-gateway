# joplin-mail-gateway

Simple (bash-based) mail gateway for the open source note taking and to-do application
[Joplin](https://joplin.cozic.net/).

## Features

- automatically fetch mails from a certain mail account and add all new mails as Joplin notes
- automatically add mail attachments
- provide tags via mail subject (with #-syntax)
- chose notebook via mail subject (with @-syntax)
- automatically run OCR on images and add text to bottom of note
- automatically add PDF text part to bottom of note

## Prerequisites

1. [**Joplin**](https://joplin.cozic.net/) terminal application installed and configured

    see https://joplin.cozic.net/

2. [**pdftoppm**](https://poppler.freedesktop.org/) and [**pdftotext**](https://poppler.freedesktop.org/) must be installed

        sudo apt update
        sudo apt install poppler-utils

    Known to work:

    - pdftoppm: version 3.03    
    - pdftotext: version 3.03    

4. [**tesseract**](https://github.com/tesseract-ocr/tesseract) must be installed

        sudo apt-get install tesseract-ocr
        
    And for German training files:
     
        sudo apt-get install tesseract-ocr-deu 

    Known to work:
    
    - tesseract: version 3.04.01

5. [**getmail**](http://pyropus.ca/software/getmail/) must be installed 

        sudo apt-get update
        sudo apt-get install getmail4

    Known to work:
    
    - getmail_fetch: version 4.48.0

6. [**ripmime**](https://github.com/inflex/ripMIME) must be installed

        sudo apt-get update
        sudo apt install ripmime

    Known to work:
    
    - ripmime: version v1.4.0.9

7. [**python 3**](https://www.python.org/) must be installed

        sudo apt-get update
        sudo apt install python3

    Known to work:
    
    - python3: version 3.5.2

## Install

1. Clone from github

        git clone https://github.com/manolitto/joplin-mail-gateway.git
        
2. Create a mail directory for incoming mails with following structure:

        ~/joplin-mailbox//new
        ~/joplin-mailbox//cur
        ~/joplin-mailbox//tmp

3. Create a log directory

        sudo mkdir /var/log/fetch-joplin-mails
        sudo chown $USER /var/log/fetch-joplin-mails
        
4. Create a new mail account at your preferred email provider that supports POP3
        
5. Change default configuration (if necessary) - see below
   
6. Test your configuration   
        
        ./fetch-joplin-mails.sh "POP3_USER" "POP3_PW" 
        
7. Add cron job

        crontab -e

    Add the following line (replace POP3_USER and POP3_PW accordingly):

        */5 * * * * ~/joplin-mail-gateway/fetch-joplin-mails.sh "POP3_USER" "POP3_PW" >>/var/log/fetch-joplin-mails/fetch.log 2>&1           

## Configuration

#### Mail provider

    _mail-functions.sh:
        readonly POP3_HOST="pop.gmail.com"
        readonly POP3_PORT=995

#### Default title (in case of empty mail subject)

    _joplin-functions.sh:
        readonly DEFAULT_TITLE_PREFIX="Neue Notiz"

#### Default notebook (in case no notebook is given in mail subject)
        
    _joplin-functions.sh:
        readonly DEFAULT_NOTEBOOK="Import"
