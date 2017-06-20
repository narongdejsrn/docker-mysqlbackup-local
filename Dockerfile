FROM phusion/baseimage:latest

MAINTAINER Narongdej Sarnsuwan <narongdej@sarnsuwan.com>

ENV TZ Asia/Bangkok

RUN echo $TZ > /etc/timezone && \
    apt-get update && apt-get install -y tzdata && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean

ADD crontab /etc/cron.d/BACKUP
RUN chmod 0644 /etc/cron.d/BACKUP
RUN touch /var/log/cron.log

RUN apt-get -qqy update && \
  DEBIAN_FRONTEND=noninteractive apt-get -qqy install rsyslog lsb-release cron mysql-client python-pip && \
  apt-get -qqy clean

RUN mkdir -p /backup/data
RUN mkdir -p /app

ADD start-cron.sh /usr/bin/start-cron.sh
RUN chmod +x /usr/bin/start-cron.sh

ENV DBS="" MYSQL_ROOT_PWD="" MAX_BACKUPS=""

COPY backup.sh /

RUN chmod 777 /backup.sh

CMD /sbin/my_init
