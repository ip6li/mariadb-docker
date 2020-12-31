#!/usr/bin/env bash

count=0
while true; do
  /usr/bin/mysqladmin status > /dev/null 2> /dev/null
  if [ $? -eq 0 ]; then
    break;
  else
    sleep 1
    let count=$count+1
    if [ $count -gt 60 ]; then
      echo "Timeout"
      exit 1
    fi
  fi
done

echo 'select 1;' | mysql --batch --user=root > /dev/null 2> /dev/null
if [ $? -eq 0 ]; then
  if [ -z "$MYSQL_PASSWORD" ]; then
    echo "fatal: MYSQL_PASSWORD not set"
  fi
  if [ -z "$HEALTHCHECK_PASSWORD" ]; then
    echo "fatal: HEALTHCHECK_PASSWORD not set"
  fi

  SQL="GRANT USAGE ON *.* TO 'docker-healthcheck'@'127.0.0.1' IDENTIFIED BY '$HEALTHCHECK_PASSWORD';"
  echo "$SQL" | mysql --batch --user=root > /dev/null 2> /dev/null
  res=$?
  HEALTHCHECK_PASSWORD="*"
  if [ $? -ne 0 ]; then
    echo "fatal: Failed to set healthcheck password"
    exit 1
  fi

  /usr/bin/mysqladmin password "$MYSQL_PASSWORD"
  res=$?
  unset MYSQL_PASSWORD
  if [ $res -ne 0 ]; then
    echo "fatal: Failed to set root password"
    exit 1
  fi

fi

exit 0

