#!/usr/bin/env bash

if [ -e /run/mysqld ]; then
  mkdir /run/mysqld
fi

chown -R mysql:mysql /var/lib/mysql /run/mysqld
if [ ! -f /var/lib/mysql/ibdata1 ]; then
  /usr/bin/mysql_install_db
fi

/usr/bin/mysqld_safe

tail -f /dev/null

