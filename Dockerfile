FROM centos:7

RUN yum update
RUN yum install -y epel-release wget gcc
RUN yum group install -y "Development Tools"
RUN yum install -y python-devel python-setuptools python-pip
RUN yum install -y automake
RUN pip install --upgrade pip
RUN pip install virtualenv

# Install Basic Browser
ENV BASIC_DIR=/opt/basic
COPY basic.tar.gz setup.sh /tmp/
RUN cd /tmp && bash setup.sh

RUN yum update
RUN yum install -y pcre pcre-devel xz xz-devel bzip2-devel zlib-devel

RUN yum install -y bison git-core supervisor

WORKDIR /tmp
RUN git clone https://github.com/swig/swig.git
RUN cd swig && wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.gz && \
    bash Tools/pcre-build.sh
RUN cd /tmp/swig && ./autogen.sh && ./configure && make && make install

RUN yum install -y boost boost-devel boost-system boost-filesystem boost-thread

# mysql installation
RUN wget -q http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
RUN rpm -ivh mysql-community-release-el7-5.noarch.rpm
RUN yum -y update

# install mysql

RUN yum -y install mysql-server
RUN yum -y install mysql-devel
RUN pip install mysql-python
ADD bind_0.cnf /etc/mysql/conf.d/bind_0.cnf

ENV MYSQL_ROOT_PASSWORD 'password'
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod 700 /entrypoint.sh
RUN chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
RUN . /entrypoint.sh mysqld --datadir=/var/lib/mysql --user=mysql
ADD run.sh /run.sh
RUN chmod 755 /*.sh


VOLUME ["/var/lib/mysql"]
VOLUME ["/var/run/mysqld"]
RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld /var/lib/mysql
#RUN . /entrypoint.sh mysqld --datadir=/var/lib/mysql --user=mysql

HEALTHCHECK \
    --interval=1s \
    --timeout=1s \
    --retries=10 \
    CMD ["/usr/bin/healthcheck"]

WORKDIR /opt/basic
RUN /usr/bin/python2.7 setup.py $BASIC_DIR/extsds-bin \
        $BASIC_DIR/pytools/ --python=$BASIC_DIR/_py

RUN $BASIC_DIR/_py/bin/python -m pip uninstall -y pymongo
RUN $BASIC_DIR/_py/bin/python -m pip install pymongo==2.3


# install mongodb
ADD mongodb-org.repo /etc/yum.repos.d/mongodb-org.repo
RUN yum -y install mongodb-org
VOLUME ["/data/db"]
#RUN sleep 10 && $BASIC_DIR/_py/bin/python $BASIC_DIR/manage.py syncdb
#RUN mongod --shutdown
COPY syncdb.sh /syncdb.sh
RUN chmod +x /syncdb.sh && sh /syncdb.sh

EXPOSE 3306/tcp
EXPOSE 27017/tcp
EXPOSE 8000/tcp

RUN yum clean all && \
    rm -rf /var/lib/apt/lists/* \
    /tmp/* /var/tmp/*

RUN pip install supervisor-stdout
ADD supervisord.conf /etc/supervisord.conf
ADD run_basic.sh /run_basic.sh
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BASIC_DIR/_py/lib/python2.7/site-packages/extsds/
ENV LANG "en_US.UTF-8"
#ENTRYPOINT ["/run.sh"]
