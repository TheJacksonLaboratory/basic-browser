#!/bin/bash

#sleep 10 ;

#mysqld --datadir=/var/lib/mysql --user=mysql;
su mysql -c /usr/bin/mysqld_safe &
sleep 5;
mongod &
#$BASIC_DIR/_py/bin/python $BASIC_DIR/manage.py syncdb --noinput;
sleep 5;
#echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'pass')" | $BASIC_DIR/_py/bin/python $BASIC_DIR/manage.py shell;
mongod --shutdown;
mysqladmin shutdown
