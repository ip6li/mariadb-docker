FROM debian:trixie-slim
LABEL Christian Felsing <support@felsing.net>

ARG hostname=mysql
ARG domain=example.com
ARG fqname=${hostname}.${domain}

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y apt-utils
RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
  locales

RUN sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG de_DE.UTF-8
ENV LANGUAGE de_DE:de
ENV LC_ALL de_DE.UTF-8

RUN DEBIAN_FRONTEND=noninteractive apt update && apt -q -y full-upgrade

# Install Postfix.
RUN echo "postfix postfix/main_mailer_type string Internet site" > preseed.txt
RUN echo "postfix postfix/mailname string ${fqname}" >> preseed.txt
# Use Mailbox format.
RUN debconf-set-selections preseed.txt
RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
  postfix

RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
  procps \
  cron \
  curl \
  rsyslog \
  mariadb-server

ADD ./50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
ADD ./50-mysqld_safe.cnf /etc/mysql/mariadb.conf.d/50-mysqld_safe.cnf

RUN mv /etc/rsyslog.conf /etc/rsyslog.conf.ORIG
COPY ./rsyslog.conf /etc/rsyslog.conf

ADD ./post-init.sh /tmp/post-init.sh
RUN chown root:root /tmp/post-init.sh && chmod 700 /tmp/post-init.sh

LABEL MYSQL="mariadb"

COPY ./entrypoint.sh /root/entrypoint.sh
RUN chmod 700 /root/entrypoint.sh
ENTRYPOINT [ "/root/entrypoint.sh" ]

