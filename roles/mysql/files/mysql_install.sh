#!/bin/bash
DBDIR='/data/mysql/data'
PASSWD='bingoclo123'
[ -d $DBDIR ] || mkdir $DBDIR -p
yum install cmake make gcc-c++ bison-devel ncurses-devel -y
id mysql &> /dev/null
if [ $? -ne 0 ];then
 useradd mysql -s /sbin/nologin -M
fi
chown -R mysql.mysql $DBDIR
cd /tmp/
tar xf mysql-5.6.27.tar.gz
cd mysql-5.6.27
cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_DATADIR=$DBDIR \
-DMYSQL_UNIX_ADDR=$DBDIR/mysql.sock \
-DDEFAULT_CHARSET=utf8 \
-DEXTRA_CHARSETS=all \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_READLINE=1 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_EMBEDDED_SERVER=1
if [ $? != 0 ];then
 echo "cmake error!"
 exit 1
fi
make && make install
if [ $? -ne 0 ];then
 echo "install mysql is failed!" && /bin/false
fi
sleep 2
ln -s /usr/local/mysql/bin/* /usr/bin/
cp -f /usr/local/mysql/support-files/my-default.cnf /etc/my.cnf
cp -f /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
chmod 700 /etc/init.d/mysqld
/usr/local/mysql/scripts/mysql_install_db  --basedir=/usr/local/mysql --datadir=$DBDIR --user=mysql
if [ $? -ne 0 ];then
 echo "install mysql is failed!" && /bin/false
fi
/etc/init.d/mysqld start
if [ $? -ne 0 ];then
 echo "install mysql is failed!" && /bin/false
fi
chkconfig --add mysqld
chkconfig mysqld on
/usr/local/mysql/bin/mysql -e "update mysql.user set password=password('$PASSWD') where host='localhost' and user='root';"
/usr/local/mysql/bin/mysql -e "update mysql.user set password=password('$PASSWD') where host='127.0.0.1' and user='root';"
/usr/local/mysql/bin/mysql -e "delete from mysql.user where password='';"
/usr/local/mysql/bin/mysql -e "flush privileges;"
if [ $? -eq 0 ];then
 echo "ins_done"
fi