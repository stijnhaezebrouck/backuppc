FROM debian:jessie


ENV BACKUPPC_INITIAL_CONFIG /backuppc_initial_config
ENV BACKUPPC_INITIAL_DATA /backuppc_initial_data
ENV BACKUPPC_CONFIG /etc/backuppc
ENV BACKUPPC_DATA /var/lib/backuppc
ENV RESET_PERMISSIONS false
ENV START /usr/local/bin/dockerstart.sh


RUN \
    # create user/group according to https://wiki.archlinux.org/index.php/DeveloperWiki:UID_/_GID_Database
    groupadd -g 126 backuppc && \
    useradd -u 126 -d /etc/backuppc -g 126 -M -s /bin/bash backuppc && \

    # install required packages
    apt-get update -y && \
    echo "backuppc backuppc/reconfigure-webserver multiselect apache2" | debconf-set-selections && \
    apt-get install -y debconf-utils backuppc supervisor && \

    # set password to backuppc
    htpasswd -b $BACKUPPC_CONFIG/htpasswd backuppc backuppc && \

    # Remove host 'localhost' from package generated config
    sed -i 's/^localhost.*//g' $BACKUPPC_CONFIG/hosts

ADD .msmtprc.template.gmail /etc/backuppc/.msmtprc.template.gmail

RUN \
    # copy initial generated config and data
    mkdir -p $BACKUPPC_INITIAL_CONFIG $BACKUPPC_INITIAL_DATA && \
    rsync -a /etc/backuppc/* $BACKUPPC_INITIAL_CONFIG && \
    rsync -a /var/lib/backuppc/* $BACKUPPC_INITIAL_DATA

COPY root-index.html /var/www/html/index.html
ADD supervisord.conf /etc/supervisor/conf.d/backuppc.conf

EXPOSE 80
VOLUME $BACKUPPC_CONFIG

ADD dockerstart.sh $START
# make start script executable
RUN chmod ugo+x $START

RUN apt-get install -y msmtp msmtp-mta
ADD msmtprc /etc/msmtprc

CMD $START
