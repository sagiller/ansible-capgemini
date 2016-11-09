#!/bin/bash
yum -y install zlib zlib-devel openssl openssl-devel pcre-devel
groupadd -r nginx
useradd -s /sbin/nologin -g nginx -r nginx
cd /tmp
tar xf nginx-1.8.0.tar.gz;cd nginx-1.8.0
mkdir /var/run/nginx/;chown nginx.nginx /var/run/nginx/
./configure \
--prefix=/usr \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--pid-path=/var/run/nginx/nginx.pid \
--user=nginx \
--group=nginx \
--with-http_ssl_module
make && make install
sed  "/^\s*index / i proxy_pass http://localhost:8080;" /etc/nginx/nginx.conf
/usr/sbin/nginx 
sed