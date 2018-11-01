#!/bin/bash
admin_username=$BASIC_ADMIN_USERNAME
admin_password=$BASIC_ADMIN_PASSWORD
admin_email=$BASIC_ADMIN_EMAIL


sleep 5;
$BASIC_DIR/_py/bin/python $BASIC_DIR/manage.py syncdb --noinput;
sleep 5;
echo "from django.contrib.auth.models import User; User.objects.create_superuser('$admin_username', '$admin_email', '$admin_password')" | $BASIC_DIR/_py/bin/python /opt/basic/manage.py shell;
sleep 5;
/opt/basic/_py/bin/python /opt/basic/manage.py runserver 0.0.0.0:8000;
