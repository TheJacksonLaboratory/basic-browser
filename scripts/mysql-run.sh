#!/bin/bash
set -e

mysql_install_db --user=mysql --datadir=/var/lib/mysql

TEMP_FILE='/tmp/mysql-first-time.sql'
cat > "$TEMP_FILE" <<-EOSQL
     CREATE DATABASE basicdb;
     GRANT ALL ON basicdb.* TO basicuser IDENTIFIED BY "";
     FLUSH PRIVILEGES ;
     CREATE USER 'basicuser'@'localhost' IDENTIFIED BY '' ;
     GRANT ALL PRIVILEGES ON *.* TO 'basicuser'@'localhost';
     FLUSH PRIVILEGES ;
EOSQL

"$@" --init-file="$TEMP_FILE" &

echo "waiting"
sleep 10

mysqladmin shutdown

chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
