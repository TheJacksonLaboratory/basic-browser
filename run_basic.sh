#!/bin/bash
sleep 5;
$BASIC_DIR/_py/bin/python $BASIC_DIR/manage.py syncdb --noinput;
sleep 5;
echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'pass')" | $BASIC_DIR/_py/bin/python /opt/basic/manage.py shell;
sleep 5;
/opt/basic/_py/bin/python /opt/basic/manage.py runserver 0.0.0.0:8000;
sleep 5;
