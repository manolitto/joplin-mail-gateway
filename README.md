# joplin-mail-gateway

Simple (bash-based) mail gateway for the open source note taking and to-do application Joplin

## Prerequisites

1. Joplin (Terminal application) installed and configured

    see https://joplin.cozic.net/

2. **pdftoppm** and **pdftotext** must be installed

        sudo apt update
        sudo apt install poppler-utils

    Known to work:

    - pdftoppm: version 3.03    
    - pdftotext: version 3.03    

4. **tesseract** must be installed

        sudo apt-get install tesseract-ocr
        
    And for German training files:
     
        sudo apt-get install tesseract-ocr-deu 

    Known to work:
    
    - tesseract: version 3.04.01

5. **getmail** must be installed 

        sudo apt-get update
        sudo apt-get install getmail4

    Known to work:
    
    - getmail_fetch: version 4.48.0

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
        
4. Add cron job

        crontab -e

    Add the following line (replace POP3_USER and POP3_PW accordingly):

        */5 * * * * ~/joplin-mail-gateway/fetch-joplin-mails.sh "POP3_USER" "POP3_PW" >>/var/log/fetch-joplin-mails/fetch.log 2>&1           
