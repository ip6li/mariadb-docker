from debian:buster-slim
maintainer Christian Felsing <support@felsing.net>

ARG hostname=mysql
ARG domain=felsing.net
ARG fqname=${hostname}.${domain}

run DEBIAN_FRONTEND=noninteractive apt-get update
run DEBIAN_FRONTEND=noninteractive apt-get install -q -y apt-utils
run DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
  locales

RUN sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG de_DE.UTF-8
ENV LANGUAGE de_DE:de
ENV LC_ALL de_DE.UTF-8

run DEBIAN_FRONTEND=noninteractive apt update && apt -q -y full-upgrade

# Install Postfix.
run echo "postfix postfix/main_mailer_type string Internet site" > preseed.txt
run echo "postfix postfix/mailname string ${fqname}" >> preseed.txt
# Use Mailbox format.
run debconf-set-selections preseed.txt
run DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
  postfix

run DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
  procps \
  cron \
  curl \
  mariadb-server

ADD ./50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
ADD ./50-mysqld_safe.cnf /etc/mysql/mariadb.conf.d/50-mysqld_safe.cnf

ADD ./post-init.sh /tmp/post-init.sh
RUN chown root:root /tmp/post-init.sh && chmod 700 /tmp/post-init.sh

COPY ./entrypoint.sh /root/entrypoint.sh
RUN chmod 700 /root/entrypoint.sh
ENTRYPOINT [ "/root/entrypoint.sh" ]

