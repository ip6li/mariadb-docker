#!/usr/bin/env bash

if [ -e /run/mysqld ]; then
  mkdir /run/mysqld
fi

/usr/sbin/usermod -a -G tty mysql

chown -R mysql:mysql /var/lib/mysql

if [ -d /run/mysqld ]; then
  chown -R mysql:mysql /run/mysqld
fi

if [ ! -f /var/lib/mysql/ibdata1 ]; then
  /usr/bin/mysql_install_db
fi

/tmp/post-init.sh &

unset MYSQL_PASSWORD
unset HEALTHCHECK_PASSWORD

/usr/sbin/rsyslogd -n &

/usr/bin/mysqld_safe --syslog

