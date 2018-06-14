#!/bin/bash

#sleep 10 ;

#mysqld --datadir=/var/lib/mysql --user=mysql;
su mysql -c /usr/bin/mysqld_safe &
sleep 5;
mongod &
sleep 5;
$BASIC_DIR/_py/bin/python $BASIC_DIR/manage.py syncdb --noinput;
mongod --shutdown;
mysqladmin shutdown
