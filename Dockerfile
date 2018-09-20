FROM centos:centos7

ENV BASIC_DIR=/opt/basic
ENV MYSQL_ROOT_PASSWORD 'password'
ENV LANG "en_US.UTF-8"
ENV LD_LIBRARY_PATH $BASIC_DIR/_py/lib/python2.7/site-packages/extsds/

# update and install basic utils
RUN yum -y update
RUN yum install -y epel-release wget gcc
RUN yum group install -y "Development Tools"
RUN yum install -y python-devel python-setuptools python-pip
RUN yum install -y automake
RUN pip install --upgrade pip
RUN pip install virtualenv

# copy Basic Browser source code
COPY basic.tar.gz scripts/basic_setup.sh /tmp/
RUN cd /tmp && bash basic_setup.sh

# Install zlib, XZ, pcre
RUN yum -y update
RUN yum install -y pcre \
    pcre-devel \
    xz xz-devel \
    bzip2-devel \
    zlib-devel \
    bison \
    git-core \
    supervisor

# Install PCRE
WORKDIR /tmp 
RUN git clone https://github.com/swig/swig.git
RUN cd /tmp/swig && wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.gz && \
    bash Tools/pcre-build.sh
RUN cd /tmp/swig && ./autogen.sh && ./configure && make && make install

# Install Boost
RUN yum install -y boost boost-devel \
    boost-system boost-filesystem boost-thread

# mysql installation
RUN wget -q http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
RUN rpm -ivh mysql-community-release-el7-5.noarch.rpm
RUN yum -y update
RUN yum -y install mysql-server
RUN yum -y install mysql-devel
RUN pip install mysql-python
ADD confs/bind_0.cnf /etc/mysql/conf.d/bind_0.cnf

# create mysql database
COPY scripts/mysql-run.sh /mysql-run.sh
RUN chmod 700 /mysql-run.sh
RUN chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
RUN . /mysql-run.sh mysqld --datadir=/var/lib/mysql --user=mysql
ADD scripts/run.sh /run.sh
RUN chmod 755 /*.sh

# create mysql volume
VOLUME ["/var/lib/mysql"]
VOLUME ["/var/run/mysqld"]
RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

# Run the setup script
WORKDIR $BASIC_DIR
RUN /usr/bin/python2.7 setup.py $BASIC_DIR/extsds-bin \
        $BASIC_DIR/pytools/ --python=$BASIC_DIR/_py

# Downgrade pymongo to version 2.3
RUN $BASIC_DIR/_py/bin/python -m pip uninstall -y pymongo
RUN $BASIC_DIR/_py/bin/python -m pip install pymongo==2.3

# install mongodb
ADD confs/mongodb-org.repo /etc/yum.repos.d/mongodb-org.repo
RUN yum -y install mongodb-org
VOLUME ["/data/db"]
COPY scripts/syncdb.sh /syncdb.sh
RUN chmod +x /syncdb.sh && sh /syncdb.sh

RUN yum clean all && \
    rm -rf /var/lib/apt/lists/* \
    /tmp/* /var/tmp/*

# add supervisor conf
RUN pip install supervisor-stdout
ADD confs/supervisord.conf /etc/supervisord.conf
ADD scripts/run_basic.sh /run_basic.sh

# Fix missing boost lib for BASIC extsds library
RUN ln -s /usr/lib64/libboost_thread-mt.so.1.53.0 /usr/lib64/libboost_thread-mt.so.5
RUN ln -s /usr/lib64/libboost_date_time-mt.so.1.53.0 /usr/lib64/libboost_date_time-mt.so.5
RUN ln -s /usr/lib64/libboost_system-mt.so.1.53.0 /usr/lib64/libboost_system-mt.so.5
RUN ln -s /usr/lib64/libboost_filesystem-mt.so.1.53.0 /usr/lib64/libboost_filesystem-mt.so.5
RUN ln -s /usr/lib64/libboost_iostreams-mt.so.1.53.0 /usr/lib64/libboost_iostreams-mt.so.5
RUN ln -s /usr/lib64/libboost_system.so.1.53.0 /usr/lib64/libboost_system.so.1.40.0

# install gis utils
RUN cd $BASIC_DIR/ds && $BASIC_DIR/_py/bin/python setup.py install

EXPOSE 3306/tcp
EXPOSE 27017/tcp
EXPOSE 8000/tcp

ENTRYPOINT ["/run.sh"]
