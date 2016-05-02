#!/bin/bash


#create the /etc/my.cnf with custom settings
cat <<EOF > /etc/my.cnf
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock

#ZR
group_concat_max_len = 1048576
max_allowed_packet=100M
#log=/var/log/mysqld-query.log
query_cache_size=52428800
query_cache_type=1
query_cache_limit=5242880
default_storage_engine=MYISAM


symbolic-links=0

[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid
wait_timeout=28800
interactive_timeout=28800

#
# include all files from the config directory
#
!includedir /etc/my.cnf.d
EOF

#create initial DB for analysis
mysql_install_db --user=mysql --basedir=/usr/ --ldata=/var/lib/mysql/
/bin/sh /usr/bin/mysqld_safe --basedir=/usr --datadir=/var/lib/mysql --plugin-dir=/usr/lib64/mysql/plugin --user=mysql --log-error=/var/log/mariadb/mariadb.log --pid-file=/var/run/mariadb/mariadb.pid --socket=/var/lib/mysql/mysql.sock &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -e "status" 
    RET=$?
done
echo "create database analysis"  | mysql
echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'dockerG0d';flush privileges;" | mysql

#populate the DB with initial data
zcat /ecdp/dbdump_tcga.sql.gz | mysql analysis
mysqladmin shutdown



#pull ecdp from git
mkdir /root/.ssh && chmod 700 /root/.ssh
cd /ecdp
ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts
ssh-agent bash -c 'ssh-add /ecdp/deploy.key;git clone git@bitbucket.org:zackramjan/ecdp.git;cd ecdp;git fetch; git checkout release'
unzip ecdp/eccpgxt.zip
mv war /var/lib/tomcat/webapps/ecdp
chown -R tomcat.tomcat /var/lib/tomcat/webapps/ecdp
ln -s /var/lib/tomcat/webapps/ecdp /var/lib/tomcat/webapps/ROOT

