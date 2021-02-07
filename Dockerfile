FROM node:10

LABEL maintainer="g.letellier@gmail.com"

# This docker file automatically install joplin + email gateway and starts
# forwarding notes

RUN apt-get update && apt-get install -y \
    libsecret-1-dev \
    cron \
    poppler-utils \
    tesseract-ocr \
    tesseract-ocr-deu \
    getmail4 \
    ripmime \
    python3 \
    && rm -rf /var/lib/apt/lists/*

USER node

ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
RUN npm install -g joplin

COPY joplin-config.json /home/node/joplin-config.json
RUN /home/node/.npm-global/bin/joplin config --import-file /home/node/joplin-config.json

USER 0

RUN ln -s /home/node/.npm-global/bin/joplin /usr/bin/joplin

RUN mkdir -p /home/node/joplin-mailbox/new
RUN mkdir -p /home/node/joplin-mailbox/cur
RUN mkdir -p /home/node/joplin-mailbox/tmp

RUN echo "SHELL=/bin/bash" > /home/node/joplin.cron
RUN echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" >>  /home/node/joplin.cron
RUN echo "*/5 * * * * /home/node/fetch-joplin-mails.sh >> /home/node/sync.log 2>&1" >> /home/node/joplin.cron
RUN echo "# An empty line is required at the end of this file for a valid cron file."
RUN crontab -u node /home/node/joplin.cron
RUN touch /home/node/sync.log

COPY . /home/node

RUN chown  node /home/node/*
RUN chown -R node /home/node/joplin-mailbox

CMD cron && tail -f /home/node/sync.log